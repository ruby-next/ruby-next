# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class EndlessMethod < Base
        NAME = "endless-method"
        SYNTAX_PROBE = "obj = Object.new; def obj.foo() = 42"
        MIN_SUPPORTED_VERSION = Gem::Version.new("3.0.0")

        unless Parser::Meta::NODE_TYPES.include?(:def_e)
          def on_def(node)
            return on_def_e(node) if node.loc.end.nil?
            super(node)
          end
        end

        def on_def_e(node)
          context.track! self

          replace(node.loc.assignment, "; ")
          insert_after(node.loc.expression, "; end")

          new_loc = node.loc.dup
          new_loc.instance_variable_set(:@end, node.loc.expression)

          process(
            node.updated(
              :def,
              node.children,
              location: new_loc
            )
          )
        end

        unless Parser::Meta::NODE_TYPES.include?(:def_e)
          def on_defs(node)
            return on_defs_e(node) if node.loc.end.nil?
            super(node)
          end
        end

        def on_defs_e(node)
          context.track! self

          replace(node.loc.assignment, "; ")
          insert_after(node.loc.expression, "; end")

          new_loc = node.loc.dup
          new_loc.instance_variable_set(:@end, node.loc.expression)

          process(
            node.updated(
              :defs,
              node.children,
              location: new_loc
            )
          )
        end
      end
    end
  end
end
