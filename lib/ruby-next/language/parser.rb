# frozen_string_literal: true

if RubyNext.edge_syntax? || RubyNext.proposed_syntax?
  require "parser/rubynext"
else
  # First, try loading Prism
  begin
    require "parser/prism"
  rescue LoadError
    require "parser/ruby33"
  end
end

module RubyNext
  module Language
    module BuilderExt
      def match_pattern(lhs, match_t, rhs)
        n(:match_pattern, [lhs, rhs],
          binary_op_map(lhs, match_t, rhs))
      end

      def match_pattern_p(lhs, match_t, rhs)
        n(:match_pattern_p, [lhs, rhs],
          binary_op_map(lhs, match_t, rhs))
      end
    end

    class Builder < ::Parser::Builders::Default
      modernize

      unless method_defined?(:match_pattern_p)
        include BuilderExt
      end
    end

    class << self
      if defined?(::Parser::RubyNext)
        def parser_class
          ::Parser::RubyNext
        end
      elsif defined?(::Parser::Prism)
        def parser_class
          ::Parser::Prism
        end
      else
        def parser_class
          ::Parser::Ruby33
        end
      end

      def parser
        parser_class.new(Builder.new).tap do |prs|
          prs.diagnostics.tap do |diagnostics|
            diagnostics.all_errors_are_fatal = true
          end
        end
      end

      def parse(source, file = "(string)")
        buffer = ::Parser::Source::Buffer.new(file).tap do |buffer|
          buffer.source = source
        end

        parser.parse(buffer)
      rescue ::Parser::SyntaxError => e
        raise ::SyntaxError, e.message
      end

      def parse_with_comments(source, file = "(string)")
        buffer = ::Parser::Source::Buffer.new(file).tap do |buffer|
          buffer.source = source
        end

        parser.parse_with_comments(buffer)
      rescue ::Parser::SyntaxError => e
        raise ::SyntaxError, e.message
      end
    end
  end
end
