# frozen_string_literal: true

using RubyNext

# TODO: how to add it at build time?
class NoMatchingPatternError < RuntimeError
end

module RubyNext
  module Language
    module Rewriters
      class PatternMatching < Base
        SYNTAX_PROBE = "case 0; in 0; true; else; 1; end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.0")

        MATCHEE = :__matchee__
        MATCHEE_ARR = :__matchee_arr__

        def on_case_match(node)
          context.track! self

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
            with_guard(
              send(
                :"#{clause.children[0].type}_clause",
                clause.children[0]
              ),
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

        def array_pattern_clause(node)
          s(:and,
            deconstruct_node,
            array_element(0, *node.children))
        end

        def array_element(index, head, *tail)
          send("#{head.type}_array_element", head, index).then do |node|
            next node if tail.empty?

            s(:and,
              node,
              array_element(index + 1, *tail))
          end
        end

        def match_alt_clause(node)
          children = node.children.map do |child|
            send :"#{child.type}_clause", child
          end
          s(:or, *children)
        end

        def match_alt_array_element(node, index)
          children = node.children.map do |child, i|
            send :"#{child.type}_array_element", child, index
          end
          s(:or, *children)
        end

        def match_as_clause(node, matchee = s(:lvar, MATCHEE))
          s(:and,
            case_eq_clause(node.children[0]),
            match_var_clause(node.children[1], matchee))
        end

        def match_var_clause(node, matchee = s(:lvar, MATCHEE))
          s(:or,
            s(:lvasgn, node.children[0], matchee),
            s(:true)) # rubocop:disable Lint/BooleanSymbol
        end

        def match_var_array_element(node, index)
          match_var_clause node, arr_item_at(index)
        end

        def with_guard(node, guard)
          return node unless guard

          s(:and,
            node,
            guard.children[0]).then do |expr|
            next expr unless guard.type == :unless_guard
            s(:send, expr, :!)
          end
        end

        def case_eq_clause(node)
          s(:send,
            node, :===, s(:lvar, MATCHEE))
        end

        def case_eq_array_element(node, index)
          s(:send,
            node, :===, arr_item_at(index))
        end

        def deconstruct_node
          s(:lvasgn, MATCHEE_ARR,
            s(:send,
              s(:lvar, MATCHEE), :deconstruct))
        end

        def arr_item_at(index, arr = s(:lvar, MATCHEE_ARR))
          s(:index,
            arr, s(:int, index))
        end

        def no_matching_pattern
          s(:send, s(:const, nil, :Kernel), :raise,
            s(:const, nil, :NoMatchingPatternError),
            s(:send,
              s(:lvar, MATCHEE), :inspect))
        end

        def respond_to_missing?(mid, *)
          return true if mid.match?(/_(clause|array_element)/)
          super
        end

        def method_missing(mid, *args, &block)
          return case_eq_clause(args.first) if mid.match?(/_clause$/)
          return case_eq_array_element(*args) if mid.match?(/_array_element$/)
          super
        end
      end
    end
  end
end
