# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class ItParam < Base
        using RubyNext

        NAME = "it-param"
        SYNTAX_PROBE = "proc { it.keys }.call({})"
        MIN_SUPPORTED_VERSION = Gem::Version.new("3.4.0")

        def on_block(node)
          proc_or_lambda, args, body = *node.children

          return super unless block_has_it?(body)

          context.track! self

          new_body = s(:begin,
            s(:lvasgn, :it, s(:lvar, :_1)),
            body)

          insert_before(body.loc.expression, "it = _1;")

          process(
            node.updated(:numblock, [
              proc_or_lambda,
              args,
              new_body
            ])
          )
        end

        private

        # It's important to check if the current block refers to `it` variable somewhere
        # (and not within a nested block), so we don't declare numbered params
        def block_has_it?(node)
          # traverse node children deeply
          tree = [node]

          while (child = tree.shift)
            return true if it?(child)

            if child.is_a?(Parser::AST::Node)
              tree.unshift(*child.children.select { |c| c.is_a?(Parser::AST::Node) && c.type != :block && c.type != :numblock })
            end
          end
        end

        def it?(node)
          node.is_a?(Parser::AST::Node) && (
            node.type == :send && node.children[0].nil? && node.children[1] == :it && node.children[2].nil?
          ) || ( # Prism version
            node.type == :lvar && node.children[0] == :"0it"
          )
        end
      end
    end
  end
end
