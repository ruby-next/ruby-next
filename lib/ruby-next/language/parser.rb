# frozen_string_literal: true

begin
  require "parser/prism"
rescue LoadError
  require "parser/ruby33"
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

      def check_reserved_for_numparam(name, loc)
        # We don't want to raise SyntaxError, 'cause we want to use _x vars for older Rubies.
        # The exception should be raised by Ruby itself for versions supporting numbered parameters
      end
    end

    class << self
      attr_accessor :parser_class

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

    # Set up default parser
    unless self.parser_class
      if defined?(::Parser::RubyNext)
        self.parser_class = ::Parser::RubyNext
      elsif defined?(::Parser::Prism)
        self.parser_class = ::Parser::Prism
      else
        self.parser_class = ::Parser::Ruby33
      end
    end
  end
end
