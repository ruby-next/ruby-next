# frozen_string_literal: true

require "parser/rubynext"

module RubyNext
  module Language
    class Builder < ::Parser::Builders::Default
      modernize

      # Unparser doens't support kwargs node yet
      self.emit_kwargs = false
    end

    class << self
      def parser
        ::Parser::RubyNext.new(Builder.new).tap do |prs|
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
