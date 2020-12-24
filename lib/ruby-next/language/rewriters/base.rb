# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      using RubyNext

      CUSTOM_PARSER_REQUIRED = <<~MSG
        The %s feature is not a part of the latest stable Ruby release
        and is not supported by your Parser gem version.

        Use RubyNext's parser to use it: https://github.com/ruby-next/parser

      MSG

      class Base < ::Parser::TreeRewriter
        class LocalsTracker
          attr_reader :stacks

          def initialize
            @stacks = []
          end

          def with(**locals)
            stacks << locals
            yield.tap { stacks.pop }
          end

          def [](name, suffix = nil)
            fetch(name).then do |name|
              next name unless suffix
              :"#{name}#{suffix}__"
            end
          end

          def key?(name)
            !!fetch(name) { false } # rubocop:disable Style/RedundantFetchBlock
          end

          def fetch(name)
            ind = -1

            loop do
              break stacks[ind][name] if stacks[ind].key?(name)
              ind -= 1
              break if stacks[ind].nil?
            end.then do |name|
              next name unless name.nil?

              return yield if block_given?
              raise ArgumentError, "Local var not found in scope: #{name}"
            end
          end
        end

        class << self
          # Returns true if the syntax is supported
          # by the current Ruby (performs syntax check, not version check)
          def unsupported_syntax?
            save_verbose, $VERBOSE = $VERBOSE, nil
            eval_mid = Kernel.respond_to?(:eval_without_ruby_next) ? :eval_without_ruby_next : :eval
            Kernel.send eval_mid, self::SYNTAX_PROBE, nil, __FILE__, __LINE__
            false
          rescue SyntaxError, StandardError
            true
          ensure
            $VERBOSE = save_verbose
          end

          # Returns true if the syntax is supported
          # by the specified version
          def unsupported_version?(version)
            self::MIN_SUPPORTED_VERSION > version
          end

          private

          def transform(source)
            Language.transform(source, rewriters: [self], using: false)
          end
        end

        attr_reader :locals

        def initialize(context)
          @context = context
          @locals = LocalsTracker.new
          super()
        end

        def s(type, *children)
          ::Parser::AST::Node.new(type, children)
        end

        private

        # BFS with predicate block
        def find_child(node)
          queue = [node]

          loop do
            break if queue.empty?

            child = queue.shift
            next unless child.is_a?(::Parser::AST::Node)

            return child if yield child

            queue.push(*child.children)
          end

          nil
        end

        def replace(range, ast)
          @source_rewriter&.replace(range, unparse(ast))
        end

        def remove(range)
          @source_rewriter&.remove(range)
        end

        def insert_after(range, ast)
          @source_rewriter&.insert_after(range, unparse(ast))
        end

        def insert_before(range, ast)
          @source_rewriter&.insert_before(range, unparse(ast))
        end

        def unparse(ast)
          return ast if ast.is_a?(String)

          Unparser.unparse(ast).chomp
        end

        attr_reader :context
      end
    end
  end
end
