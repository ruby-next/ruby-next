# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class EndlessMethod < Base
        NAME = "endless-method"
        SYNTAX_PROBE = "obj = Object.new; def obj.foo() = 42"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.8.0")

        def on_def_e(node)
          context.track! self

          replace(node.loc.assignment, "; ")
          insert_after(node.loc.expression, "; end")

          process(
            node.updated(
              :def,
              node.children
            )
          )
        end

        def on_defs_e(node)
          context.track! self

          replace(node.loc.assignment, "; ")
          insert_after(node.loc.expression, "; end")

          process(
            node.updated(
              :defs,
              node.children
            )
          )
        end
      end
    end
  end
end
