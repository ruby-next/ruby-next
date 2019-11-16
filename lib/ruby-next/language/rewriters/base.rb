# frozen_string_literal: true

using RubyNext

module RubyNext
  module Language
    module Rewriters
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
            Kernel.send eval_mid, self::SYNTAX_PROBE
            false
          rescue SyntaxError, NameError
            true
          ensure
            $VERBOSE = save_verbose
          end

          # Returns true if the syntax is supported
          # by the specified version
          def unsupported_version?(version)
            self::MIN_SUPPORTED_VERSION > version
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

        attr_reader :context
      end
    end
  end
end
