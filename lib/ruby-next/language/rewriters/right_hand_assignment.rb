# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class RightHandAssignment < Base
        NAME = "right-hand-assignment"
        SYNTAX_PROBE = "1 + 2 => a"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.8.0")

        def on_rasgn(node)
          context.track! self

          val_node, asgn_node = *node

          remove(val_node.loc.expression.end.join(asgn_node.loc.expression))
          insert_before(val_node.loc.expression, "#{asgn_node.loc.expression.source} = ")

          process(
            asgn_node.updated(
              nil,
              asgn_node.children + [val_node]
            )
          )
        end

        def on_mrasgn(node)
          context.track! self

          lhs, rhs = *node

          replace(lhs.loc.expression.end.join(rhs.loc.expression), ")")
          insert_before(lhs.loc.expression, "#{rhs.loc.expression.source} = (")

          process(
            node.updated(
              :masgn,
              [rhs, lhs]
            )
          )
        end
      end
    end
  end
end
