# frozen_string_literal: true

using RubyNext

module RubyNext
  module Language
    module Rewriters
      class NumberedParams < Base
        SYNTAX_PROBE = "proc { _1 }.call(1)"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.0")

        def on_numblock(node)
          context.track! self

          proc_or_lambda, num, *rest = *node.children

          node.updated(
            :block,
            [
              proc_or_lambda,
              proc_args(num),
              *rest
            ]
          )
        end

        private

        def proc_args(n)
          return s(:args, s(:procarg0, s(:arg, :_1))) if n == 1

          (1..n).map do |numero|
            s(:arg, :"_#{numero}")
          end.then do |args|
            s(:args, *args)
          end
        end
      end
    end
  end
end
