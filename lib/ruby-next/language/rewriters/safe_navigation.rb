# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class SafeNavigation < Base
        NAME = "safe-navigation"
        SYNTAX_PROBE = "nil&.x&.nil?"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.3.0")

        def on_csend(node)
          node = super(node)

          context.track! self

          receiver, *args = *node

          new_node = s(:begin,
            node.updated(
              :and,
              [
                process(safe_navigation(receiver)),
                s(:send, decsendize(receiver), *args)
              ]
            ))

          replace(node.loc.expression, new_node)

          new_node
        end

        def on_block(node)
          return super(node) unless node.children[0].type == :csend

          context.track!(self)

          new_node = s(:begin,
            super(node.updated(
              :and,
              [
                process(safe_navigation(node.children[0].children[0])),
                process(node.updated(nil, node.children.map(&method(:decsendize))))
              ]
            )))

          replace(node.loc.expression, new_node)

          new_node
        end

        def on_op_asgn(node)
          return super(node) unless node.children[0].type == :csend

          context.track!(self)

          new_node = s(:begin,
            super(node.updated(
              :and,
              [
                process(safe_navigation(node.children[0].children[0])),
                process(node.updated(nil, node.children.map(&method(:decsendize))))
              ]
            )))

          replace(node.loc.expression, new_node)

          new_node
        end

        private

        def decsendize(node)
          return node unless node.is_a?(::Parser::AST::Node) && node.type == :csend

          node.updated(:send, node.children.map(&method(:decsendize)))
        end

        # Transform: x&.y -> (!x.nil? && x.y) || nil
        # This allows us to handle `false&.to_s == "false"`
        def safe_navigation(node)
          s(:begin,
            s(:or,
              s(:send,
                s(:send, node, :nil?),
                :!),
              s(:nil)))
        end
      end
    end
  end
end
