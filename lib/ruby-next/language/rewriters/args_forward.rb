# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class ArgsForward < Base
        NAME = "args-forward"
        SYNTAX_PROBE = "obj = Object.new; def obj.foo(...) super(1, ...); end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.2")

        REST = :__rest__
        BLOCK = :__block__

        def on_forward_arg(node)
          context.track! self

          node = super(node)

          replace(node.loc.expression, "*#{REST}, &#{BLOCK}")

          node.updated(
            :args,
            [
              s(:restarg, REST),
              s(:blockarg, BLOCK)
            ]
          )
        end

        def on_send(node)
          fargs = node.children.find { |child| child.is_a?(::Parser::AST::Node) && child.type == :forwarded_args }
          return super(node) unless fargs

          process_fargs(node, fargs)
        end

        def on_super(node)
          fargs = node.children.find { |child| child.is_a?(::Parser::AST::Node) && child.type == :forwarded_args }
          return super(node) unless fargs

          process_fargs(node, fargs)
        end

        private

        def process_fargs(node, fargs)
          replace(fargs.loc.expression, "*#{REST}, &#{BLOCK}")

          process(
            node.updated(
              nil,
              [
                *node.children.take(node.children.index(fargs)),
                *forwarded_args
              ]
            )
          )
        end

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
