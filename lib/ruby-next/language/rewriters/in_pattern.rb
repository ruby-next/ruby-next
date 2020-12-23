# frozen_string_literal: true

require "ruby-next/language/rewriters/pattern_matching"

module RubyNext
  module Language
    module Rewriters
      using RubyNext

      # Separate pattern matching rewriter for Ruby 2.7 to
      # transpile only `in` patterns
      class InPattern < PatternMatching
        NAME = "pattern-matching-in"
        SYNTAX_PROBE = "1 in 2"
        MIN_SUPPORTED_VERSION = Gem::Version.new("3.0.0")

        # Make case-match no-op
        def on_case_match(node)
          node
        end

        def on_match_pattern_p(node)
          context.track! self

          @deconstructed_keys = {}
          @predicates = Predicates::Noop.new

          matchee =
            s(:begin, s(:lvasgn, MATCHEE, node.children[0]))

          pattern =
            locals.with(
              matchee: MATCHEE,
              arr: MATCHEE_ARR,
              hash: MATCHEE_HASH
            ) do
              send(
                :"#{node.children[1].type}_clause",
                node.children[1]
              )
            end

          node.updated(
            :and,
            [
              matchee,
              pattern
            ]
          ).tap do |new_node|
            replace(node.loc.expression, inline_blocks(unparse(new_node)))
          end
        end
      end
    end
  end
end
