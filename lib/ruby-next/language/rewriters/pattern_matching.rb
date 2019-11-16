# frozen_string_literal: true

using RubyNext

module RubyNext
  module Language
    module Rewriters
      class PatternMatching < Base
        SYNTAX_PROBE = "case 0; in 0; true; else; 1; end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.0")

        MATCHEE = :__matchee__
        MATCHEE_ARR = :__matchee_arr__
        MATCHEE_HASH = :__matchee_hash__

        def on_case_match(node)
          context.track! self
          context.use_ruby_next!

          @array_deconstructed = false
          @hash_deconstructed = false

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

        def const_pattern_clause(node)
          const, pattern = *node.children

          case_eq_clause(const).then do |node|
            next node if pattern.nil?

            s(:and,
              node,
              send(:"#{pattern.type}_clause", pattern))
          end
        end

        def match_alt_clause(node)
          children = node.children.map do |child|
            send :"#{child.type}_clause", child
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

        def pin_clause(node)
          case_eq_clause node.children[0]
        end

        def case_eq_clause(node, right = s(:lvar, MATCHEE))
          s(:send,
            node, :===, right)
        end

        #=========== ARRAY PATTERN (START) ===============

        def array_pattern_clause(node)
          deconstruct_node.then do |dnode|
            right =
              if node.children.empty?
                case_eq_clause(s(:array), s(:lvar, MATCHEE_ARR))
              else
                array_element(0, *node.children)
              end

            s(:and,
              dnode,
              right)
          end
        end

        alias array_pattern_with_tail_clause array_pattern_clause

        def deconstruct_node
          right = s(:send,
            s(:lvar, MATCHEE), :deconstruct)

          # only deconstruct once per case
          if @array_deconstructed
            s(:or_asgn,
              s(:lvasgn, MATCHEE_ARR),
              right)
          else
            @array_deconstructed = true
            s(:and,
              s(:or,
                s(:lvasgn, MATCHEE_ARR, right),
                s(:true)), # rubocop:disable Lint/BooleanSymbol
              s(:or,
                case_eq_clause(s(:const, nil, :Array), s(:lvar, MATCHEE_ARR)),
                raise_error(:TypeError)))
          end
        end

        def array_element(index, head, *tail)
          return array_match_rest(index, head, *tail) if head.type == :match_rest

          send("#{head.type}_array_element", head, index).then do |node|
            next node if tail.empty?

            s(:and,
              node,
              array_element(index + 1, *tail))
          end
        end

        def array_match_rest(index, node, *tail)
          child = node.children[0]
          rest = arr_rest_items(index, tail.size).then do |r|
            next r unless child
            match_var_clause(
              child,
              r
            )
          end

          return rest if tail.empty?

          s(:and,
            rest,
            array_rest_element(*tail))
        end

        def array_rest_element(head, *tail)
          send("#{head.type}_array_element", head, -(tail.size + 1)).then do |node|
            next node if tail.empty?

            s(:and,
              node,
              array_rest_element(*tail))
          end
        end

        def match_alt_array_element(node, index)
          children = node.children.map do |child, i|
            send :"#{child.type}_array_element", child, index
          end
          s(:or, *children)
        end

        def match_var_array_element(node, index)
          match_var_clause node, arr_item_at(index)
        end

        def pin_array_element(node, index)
          case_eq_array_element node.children[0], index
        end

        def case_eq_array_element(node, index)
          case_eq_clause(node, arr_item_at(index))
        end

        def arr_item_at(index, arr = s(:lvar, MATCHEE_ARR))
          index = s(:int, index) if index.is_a?(Integer)
          s(:index, arr, index)
        end

        def arr_rest_items(index, size, arr = s(:lvar, MATCHEE_ARR))
          s(:index,
            arr,
            s(:irange,
              s(:int, index),
              s(:int, -(size + 1))))
        end

        #=========== ARRAY PATTERN (END) ===============

        #=========== HASH PATTERN (START) ===============

        def hash_pattern_clause(node)
          keys = hash_pattern_keys(node.children)

          deconstruct_keys_node(keys).then do |dnode|
            right =
              if node.children.empty?
                case_eq_clause(s(:hash), s(:lvar, MATCHEE_HASH))
              else
                hash_element(*node.children)
              end

            s(:and,
              dnode,
              right)
          end
        end

        def hash_pattern_keys(children)
          return s(:nil) if children.empty?

          children.filter_map do |child|
            send("#{child.type}_hash_key", child)
          end.then { |keys| s(:array, *keys) }
        end

        def pair_hash_key(node)
          node.children[0]
        end

        def match_var_hash_key(node)
          s(:sym, node.children[0])
        end

        def deconstruct_keys_node(keys)
          right = s(:send,
            s(:lvar, MATCHEE), :deconstruct_keys, keys)

          # only deconstruct once per case
          if @hash_deconstructed
            s(:or_asgn,
              s(:lvasgn, MATCHEE_HASH),
              right)
          else
            @hash_deconstructed = true
            s(:and,
              s(:or,
                s(:lvasgn, MATCHEE_HASH, right),
                s(:true)), # rubocop:disable Lint/BooleanSymbol
              s(:or,
                case_eq_clause(s(:const, nil, :Hash), s(:lvar, MATCHEE_HASH)),
                raise_error(:TypeError)))
          end
        end

        def hash_element(head, *tail)
          # return array_match_rest(index, head, *tail) if head.type == :match_rest

          send("#{head.type}_hash_element", head).then do |node|
            next node if tail.empty?

            s(:and,
              node,
              hash_element(*tail))
          end
        end

        def pair_hash_element(node)
          key, val = *node.children
          case_eq_clause val, hash_value_at(key)
        end

        def match_var_hash_element(node)
          key = node.children[0]
          # We need to check whether key is present first
          s(:and,
            hash_has_key(key),
            match_var_clause(node, hash_value_at(key)))
        end

        def hash_value_at(key, hash = s(:lvar, MATCHEE_HASH))
          key = s(:sym, key) if key.is_a?(Symbol)
          key = s(:str, key) if key.is_a?(String)
          s(:index, hash, key)
        end

        def hash_has_key(key, hash = s(:lvar, MATCHEE_HASH))
          key = s(:sym, key) if key.is_a?(Symbol)
          key = s(:str, key) if key.is_a?(String)

          s(:send,
            hash, :key?,
            key)
        end

        #=========== HASH PATTERN (END) ===============

        def with_guard(node, guard)
          return node unless guard

          s(:and,
            node,
            guard.children[0]).then do |expr|
            next expr unless guard.type == :unless_guard
            s(:send, expr, :!)
          end
        end

        def no_matching_pattern
          raise_error :NoMatchingPatternError
        end

        def raise_error(type)
          s(:send, s(:const, nil, :Kernel), :raise,
            s(:const, nil, type),
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
