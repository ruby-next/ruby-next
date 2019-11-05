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

    class << self
      attr_accessor :rewriters

      def transform(source)
        buffer = ::Parser::Source::Buffer.new("<dynamic>")
        buffer.source = source

        Parser.parse(source).then do |ast|
          rewriters.inject(ast) do |tree, rewriter|
            rewriter.new.process(tree)
          end.then do |new_ast|
            [ast, new_ast]
          end
        end.then do |(ast, new_ast)|
          return source if ast == new_ast

          Unparser.unparse(new_ast)
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
