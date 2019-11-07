# frozen_string_literal: true

gem "parser", "~> 2.6.3.0"
gem "unparser", "~> 0.4.5"

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
    require "unparser"

    class TransformContext
      attr_reader :min_version

      def initialize
        # Minimum supported RubyNext version
        @min_version = Gem::Version.new(MIN_SUPPORTED_VERSION)
        @dirty = false
      end

      # Called by rewriter when it performs transfomrations
      def track!(rewriter)
        @dirty = true

        version = rewriter.class::MIN_VERSION
        return unless version > min_version

        @min_version = version
      end

      def dirty?
        @dirty == true
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
          end
        end
      end
    end

    self.rewriters = []

    require "ruby-next/language/rewriters/base"

    require "ruby-next/language/rewriters/pattern_matching"
    rewriters << Rewriters::PatternMatching

    require "ruby-next/language/rewriters/method_reference"
    rewriters << Rewriters::MethodReference
  end
end
