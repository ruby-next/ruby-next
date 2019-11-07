# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class MethodReference < Base
        SYNTAX_PROBE = "Language.:transform"
        MIN_VERSION = Gem::Version.new("2.7.0")

        def on_meth_ref(node)
          context.track! self

          receiver, mid = *node.children

          node.updated(
            :send,
            [
              receiver,
              :method,
              s(:sym, mid)
            ]
          )
        end
      end
    end
  end
end
