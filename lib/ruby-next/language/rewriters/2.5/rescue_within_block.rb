# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class RescueWithinBlock < Base
        NAME = "rescue-within-block"
        SYNTAX_PROBE = "lambda do
          raise 'err'
        rescue
          $! # => #<RuntimeError: err>
        end.call"

        MIN_SUPPORTED_VERSION = Gem::Version.new("2.5.0")

        def on_block(block_node)
          exception_node = block_node.children.find do |node|
            node.type == :rescue || node.type == :ensure
          end

          return unless exception_node

          context.track! self

          replace(exception_node.loc.expression, s(:kwbegin, exception_node))
        end
      end
    end
  end
end
