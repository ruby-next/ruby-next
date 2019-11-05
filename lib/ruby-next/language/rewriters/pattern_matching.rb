# frozen_string_literal: true

using RubyNext

class NoMatchingPatternError < RuntimeError
end

module RubyNext
  module Language
    module Rewriters
      class PatternMatching < Base
        MATCHEE = :__matchee__

        def on_case_match(node)
          matchee_ast =
            s(:lvasgn, MATCHEE, node.children[0])

          ifs_ast = build_if_clause(node.children[1], node.children[2..-1])

          node.updated(
            :begin,
            [
              matchee_ast, ifs_ast
            ]
          )
        end

        private

        def build_if_clause(node, rest)
          if node&.type == :in_pattern
            build_in_pattern(node, rest)
          else
            raise "Unexpected else in the middle of case ... in" if rest && rest.size > 0
            # else clause must be present
            node || no_matching_pattern
          end
        end

        def build_in_pattern(clause, rest)
          [
            send(
              :"#{clause.children[0].type}_to_if",
              clause.children[0], # pattern
              clause.children[1] # guard
            ),
            clause.children[2] || s(:nil) # expression
          ].then do |children|
            if rest && rest.size > 0
              children << build_if_clause(rest.first, rest[1..-1])
            end

            s(:if, *children)
          end
        end

        def match_alt_to_if(node, _)
          children = node.children.map do |child|
            s(:send,
              s(:lvar, MATCHEE), :==, child)
          end
          s(:or, *children)
        end

        def match_var_to_if(node, guard)
          if guard
            # Generate (x = __matchee__).object_id && <guard>
            # We use object_id 'cause it's always present and truthy
            s(:and,
              s(:send, s(:lvasgn, node.children[0], s(:lvar, MATCHEE)), :object_id),
              guard.children[0]).then do |expr|
              next expr unless guard.type == :unless_guard
              s(:send, expr, :!)
            end
          else
            s(:lvasgn, node.children[0], s(:lvar, MATCHEE))
          end
        end

        def int_to_if(node, guard)
          s(:send,
            s(:lvar, MATCHEE), :==, node)
        end

        def no_matching_pattern
          s(:send, s(:const, nil, :Kernel), :raise,
            s(:const, nil, :NoMatchingPatternError),
            s(:send,
              s(:lvar, MATCHEE), :inspect))
        end
      end
    end
  end
end
