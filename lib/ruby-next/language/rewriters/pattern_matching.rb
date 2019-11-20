# frozen_string_literal: true

using RubyNext

module RubyNext
  module Language
    module Rewriters
      using(Module.new do
        refine ::Parser::AST::Node do
          def to_ast_node
            self
          end
        end

        refine String do
          def to_ast_node
            ::Parser::AST::Node.new(:str, [self])
          end
        end

        refine Symbol do
          def to_ast_node
            ::Parser::AST::Node.new(:sym, [self])
          end
        end

        refine Integer do
          def to_ast_node
            ::Parser::AST::Node.new(:int, [self])
          end
        end
      end)

      class PatternMatching < Base
        SYNTAX_PROBE = "case 0; in 0; true; else; 1; end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("2.7.0")

        MATCHEE = :__m__
        MATCHEE_ARR = :__m_arr__
        MATCHEE_HASH = :__m_hash__

        def on_case_match(node)
          context.track! self

          @deconstructed = []

          matchee_ast =
            s(:lvasgn, MATCHEE, node.children[0])

          ifs_ast = locals.with(
            matchee: MATCHEE,
            arr: MATCHEE_ARR,
            hash: MATCHEE_HASH
          ) do
            build_if_clause(node.children[1], node.children[2..-1])
          end

          node.updated(
            :begin,
            [
              matchee_ast, ifs_ast
            ]
          )
        end

        def on_in_match(node)
          context.track! self

          @deconstructed = []

          matchee =
            s(:lvasgn, MATCHEE, node.children[0])

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
              s(:and,
                pattern,
                s(:true)) # rubocop:disable Lint/BooleanSymbol
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

        def match_as_clause(node)
          s(:and,
            case_eq_clause(node.children[0]),
            match_var_clause(node.children[1], s(:lvar, locals[:matchee])))
        end

        def match_var_clause(node, left = s(:lvar, locals[:matchee]))
          s(:or,
            s(:lvasgn, node.children[0], left),
            s(:true)) # rubocop:disable Lint/BooleanSymbol
        end

        def pin_clause(node)
          case_eq_clause node.children[0]
        end

        def case_eq_clause(node, right = s(:lvar, locals[:matchee]))
          s(:send,
            node, :===, right)
        end

        #=========== ARRAY PATTERN (START) ===============

        def array_pattern_clause(node, matchee = s(:lvar, locals[:matchee]))
          deconstruct_node(matchee).then do |dnode|
            right =
              if node.children.empty?
                case_eq_clause(s(:array), s(:lvar, locals[:arr]))
              else
                array_element(0, *node.children)
              end

            # already deconsrtructed
            next right if dnode.nil?

            # if there is no rest or tail, match the size first
            unless node.type == :array_pattern_with_tail || node.children.any? { |n| n.type == :match_rest }
              right =
                s(:and,
                  s(:send,
                    node.children.size.to_ast_node,
                    :==,
                    s(:send, s(:lvar, locals[:arr]), :size)),
                  right)
            end

            s(:and,
              dnode,
              right)
          end
        end

        alias array_pattern_with_tail_clause array_pattern_clause

        def deconstruct_node(matchee)
          # only deconstruct once per case
          return if deconstructed.include?(locals[:arr])

          context.use_ruby_next!

          right = s(:send, matchee, :deconstruct)

          deconstructed << locals[:arr]
          s(:and,
            s(:or,
              s(:lvasgn, locals[:arr], right),
              s(:true)), # rubocop:disable Lint/BooleanSymbol
            s(:or,
              case_eq_clause(s(:const, nil, :Array), s(:lvar, locals[:arr])),
              raise_error(:TypeError)))
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

        def array_pattern_array_element(node, index)
          element = arr_item_at(index)
          locals.with(arr: locals[:arr, index]) do
            array_pattern_clause(node, element)
          end
        end

        def hash_pattern_array_element(node, index)
          element = arr_item_at(index)
          locals.with(hash: locals[:arr, index]) do
            hash_pattern_clause(node, element)
          end
        end

        def match_alt_array_element(node, index)
          children = node.children.map do |child, i|
            send :"#{child.type}_array_element", child, index
          end
          s(:or, *children)
        end

        def match_var_array_element(node, index)
          match_var_clause(node, arr_item_at(index))
        end

        def pin_array_element(node, index)
          case_eq_array_element node.children[0], index
        end

        def case_eq_array_element(node, index)
          case_eq_clause(node, arr_item_at(index))
        end

        def arr_item_at(index, arr = s(:lvar, locals[:arr]))
          s(:index, arr, index.to_ast_node)
        end

        def arr_rest_items(index, size, arr = s(:lvar, locals[:arr]))
          s(:index,
            arr,
            s(:irange,
              s(:int, index),
              s(:int, -(size + 1))))
        end

        #=========== ARRAY PATTERN (END) ===============

        #=========== HASH PATTERN (START) ===============

        def hash_pattern_clause(node, matchee = s(:lvar, locals[:matchee]))
          # Optimization: avoid hash modifications when not needed
          # (we use #dup and #delete when "reading" values when **rest is present
          # to assign the rest of the hash copy to it)
          @hash_match_rest = node.children.any? { |child| child.type == :match_rest || child.type == :match_nil_pattern }
          keys = hash_pattern_keys(node.children)

          deconstruct_keys_node(keys, matchee).then do |dnode|
            right =
              if node.children.empty?
                case_eq_clause(s(:hash), s(:lvar, locals[:hash]))
              else
                hash_element(*node.children)
              end

            return dnode if right.nil?

            s(:and,
              dnode,
              right)
          end
        end

        def hash_pattern_keys(children)
          return s(:nil) if children.empty?

          children.filter_map do |child|
            # Skip ** without var
            next if child.type == :match_rest && child.children.empty?
            return s(:nil) if child.type == :match_rest || child.type == :match_nil_pattern

            send("#{child.type}_hash_key", child)
          end.then { |keys| s(:array, *keys) }
        end

        def pair_hash_key(node)
          node.children[0]
        end

        def match_var_hash_key(node)
          s(:sym, node.children[0])
        end

        def deconstruct_keys_node(keys, matchee = s(:lvar, locals[:matchee]))
          # Deconstruct once and use a copy of the hash for each pattern if we need **rest.
          hash_dup =
            if @hash_match_rest
              s(:lvasgn, locals[:hash], s(:send, s(:lvar, locals[:hash, :src]), :dup))
            else
              s(:lvasgn, locals[:hash], s(:lvar, locals[:hash, :src]))
            end

          # Create a copy of the original hash if already deconstructed
          return hash_dup if deconstructed.include?(locals[:hash])

          context.use_ruby_next!

          deconstructed << locals[:hash]

          right = s(:send,
            matchee, :deconstruct_keys, keys)

          s(:and,
            s(:or,
              s(:lvasgn, locals[:hash, :src], right),
              s(:true)), # rubocop:disable Lint/BooleanSymbol
            s(:and,
              s(:or,
                case_eq_clause(s(:const, nil, :Hash), s(:lvar, locals[:hash, :src])),
                raise_error(:TypeError)),
              hash_dup))
        end

        def hash_pattern_hash_element(node, key)
          element = hash_value_at(key)
          locals.with(hash: locals[:hash, deconstructed.size]) do
            hash_pattern_clause(node, element)
          end
        end

        def array_pattern_hash_element(node, key)
          element = hash_value_at(key)
          locals.with(arr: locals[:hash, deconstructed.size]) do
            array_pattern_clause(node, element)
          end
        end

        def hash_element(head, *tail)
          send("#{head.type}_hash_element", head).then do |node|
            next node if tail.empty?

            right = hash_element(*tail)

            next node if right.nil?

            s(:and,
              node,
              right)
          end
        end

        def pair_hash_element(node, _key = nil)
          key, val = *node.children
          send("#{val.type}_hash_element", val, key)
        end

        def match_alt_hash_element(node, key)
          element_node = s(:lvasgn, locals[:hash, :el], hash_value_at(key))

          children = locals.with(hash_element: locals[:hash, :el]) do
            node.children.map do |child, i|
              send :"#{child.type}_hash_element", child, key
            end
          end

          s(:and,
            s(:or,
              element_node,
              s(:true)), # rubocop:disable Lint/BooleanSymbol
            s(:or, *children))
        end

        def match_var_hash_element(node, key = nil)
          key ||= node.children[0]
          # We need to check whether key is present first
          s(:and,
            hash_has_key(key),
            match_var_clause(node, hash_value_at(key)))
        end

        def match_nil_pattern_hash_element(node, _key = nil)
          s(:send,
            s(:lvar, locals[:hash]),
            :empty?)
        end

        def match_rest_hash_element(node, _key = nil)
          # case {}; in **; end
          return if node.children.empty?

          child = node.children[0]

          raise ArgumentError, "Unknown hash match_rest child: #{child.type}" unless child.type == :match_var

          match_var_clause(child, s(:lvar, locals[:hash]))
        end

        def case_eq_hash_element(node, key)
          case_eq_clause node, hash_value_at(key)
        end

        def hash_value_at(key, hash = s(:lvar, locals[:hash]))
          return s(:lvar, locals.fetch(:hash_element)) if locals.key?(:hash_element)

          if @hash_match_rest
            s(:send,
              hash, :delete,
              key.to_ast_node)
          else
            s(:index,
              hash,
              key.to_ast_node)
          end
        end

        def hash_has_key(key, hash = s(:lvar, locals[:hash]))
          s(:send,
            hash, :key?,
            key.to_ast_node)
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
              s(:lvar, locals[:matchee]), :inspect))
        end

        def respond_to_missing?(mid, *)
          return true if mid.match?(/_(clause|array_element)/)
          super
        end

        def method_missing(mid, *args, &block)
          return case_eq_clause(args.first) if mid.match?(/_clause$/)
          return case_eq_array_element(*args) if mid.match?(/_array_element$/)
          return case_eq_hash_element(*args) if mid.match?(/_hash_element$/)
          super
        end

        private

        attr_reader :deconstructed
      end
    end
  end
end
