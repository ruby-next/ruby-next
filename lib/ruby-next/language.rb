# frozen_string_literal: true

gem "parser", ">= 2.7.0.0"
gem "unparser", ">= 0.4.7"

require "set"

require "ruby-next"
using RubyNext

module RubyNext
  # Language module contains tools to transpile newer Ruby syntax
  # into an older one.
  #
  # It works the following way:
  #   - Takes a Ruby source code as input
  #   - Generates the AST using the edge parser (via the `parser` gem)
  #   - Pass this AST through the list of processors (one feature = one processor)
  #   - Each processor may modify the AST
  #   - Generates a transpiled source code from the transformed AST (via the `unparser` gem)
  module Language
    require "ruby-next/language/parser"
    require "ruby-next/language/unparser"

    class TransformContext
      attr_reader :versions, :use_ruby_next

      def initialize
        # Minimum supported RubyNext version
        @min_version = MIN_SUPPORTED_VERSION
        @dirty = false
        @versions = Set.new
        @use_ruby_next = false
      end

      # Called by rewriter when it performs transfomrations
      def track!(rewriter)
        @dirty = true
        versions << rewriter.class::MIN_SUPPORTED_VERSION
      end

      def use_ruby_next!
        @use_ruby_next = true
      end

      alias use_ruby_next? use_ruby_next

      def dirty?
        @dirty == true
      end

      def min_version
        versions.min
      end

      def sorted_versions
        versions.to_a.sort
      end
    end

    class << self
      attr_accessor :rewriters

      def transform(source, rewriters: self.rewriters, eval: false, context: TransformContext.new)
        Parser.parse(source).then do |ast|
          rewriters.inject(ast) do |tree, rewriter|
            rewriter.new(context).process(tree)
          end.then do |new_ast|
            next source unless context.dirty?

            Unparser.unparse(new_ast)
          end.then do |source|
            next source if eval || !context.use_ruby_next?

            Core.inject! source.dup
          end
        end
      end
    end

    self.rewriters = []

    require "ruby-next/language/rewriters/base"

    require "ruby-next/language/rewriters/endless_range"
    rewriters << Rewriters::EndlessRange

    require "ruby-next/language/rewriters/pattern_matching"
    rewriters << Rewriters::PatternMatching

    require "ruby-next/language/rewriters/args_forward"
    rewriters << Rewriters::ArgsForward

    require "ruby-next/language/rewriters/numbered_params"
    rewriters << Rewriters::NumberedParams

    if ENV["RUBY_NEXT_ENABLE_METHOD_REFERENCE"] == "1"
      require "ruby-next/language/rewriters/method_reference"
      RubyNext::Language.rewriters << RubyNext::Language::Rewriters::MethodReference
    end
  end
end
