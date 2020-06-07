# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class ArgsForward < Base
        NAME = "args-forward"
        SYNTAX_PROBE = "obj = Object.new; def obj.foo(...) super(...); end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.0")

        REST = :__rest__
        BLOCK = :__block__

        def on_forward_args(node)
          context.track! self

          replace(node.loc.expression, "(*#{REST}, &#{BLOCK})")

          node.updated(
            :args,
            [
              s(:restarg, REST),
              s(:blockarg, BLOCK)
            ]
          )
        end

        def on_send(node)
          return super(node) unless node.children[2]&.type == :forwarded_args

          replace(node.children[2].loc.expression, "*#{REST}, &#{BLOCK}")

          process(
            node.updated(
              nil,
              [
                *node.children[0..1],
                *forwarded_args
              ]
            )
          )
        end

        def on_super(node)
          return super(node) unless node.children[0]&.type == :forwarded_args

          replace(node.children[0].loc.expression, "*#{REST}, &#{BLOCK}")

          node.updated(
            nil,
            forwarded_args
          )
        end

        private

        def forwarded_args
          [
            s(:splat, s(:lvar, REST)),
            s(:block_pass, s(:lvar, BLOCK))
          ]
        end
      end
    end
  end
end
