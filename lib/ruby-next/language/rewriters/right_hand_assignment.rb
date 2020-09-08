# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class RightHandAssignment < Base
        NAME = "right-hand-assignment"
        SYNTAX_PROBE = "1 + 2 => a"
        MIN_SUPPORTED_VERSION = Gem::Version.new("3.0.0")

        def on_rasgn(node)
          context.track! self

          node = super(node)

          val_node, asgn_node = *node

          remove(val_node.loc.expression.end.join(asgn_node.loc.expression))
          insert_before(val_node.loc.expression, "#{asgn_node.loc.expression.source} = ")

          asgn_node.updated(
            nil,
            asgn_node.children + [val_node]
          )
        end

        def on_vasgn(node)
          return super(node) unless rightward?(node)

          context.track! self

          name, val_node = *node

          remove(val_node.loc.expression.end.join(node.loc.name))
          insert_before(val_node.loc.expression, "#{name} = ")

          super(node)
        end

        def on_casgn(node)
          return super(node) unless rightward?(node)

          context.track! self

          scope_node, name, val_node = *node

          if scope_node
            scope = scope_node.type == :cbase ? scope_node.loc.expression.source : "#{scope_node.loc.expression.source}::"
            name = "#{scope}#{name}"
          end

          remove(val_node.loc.expression.end.join(node.loc.name))
          insert_before(val_node.loc.expression, "#{name} = ")

          super(node)
        end

        def on_mrasgn(node)
          context.track! self

          node = super(node)

          lhs, rhs = *node

          replace(lhs.loc.expression.end.join(rhs.loc.expression), ")")
          insert_before(lhs.loc.expression, "#{rhs.loc.expression.source} = (")

          node.updated(
            :masgn,
            [rhs, lhs]
          )
        end

        def on_masgn(node)
          return super(node) unless rightward?(node)

          context.track! self

          rhs, lhs = *node

          replace(lhs.loc.expression.end.join(rhs.loc.expression), ")")
          insert_before(lhs.loc.expression, "#{rhs.loc.expression.source} = (")

          super(node)
        end

        private

        def rightward?(node)
          # Location could be empty for node built by rewriters
          return false unless node.loc&.operator

          assignee_loc =
            if node.type == :masgn
              node.children[0].loc.expression
            else
              node.loc.name
            end

          return false unless assignee_loc

          assignee_loc.begin_pos > node.loc.operator.end_pos
        end
      end
    end
  end
end
