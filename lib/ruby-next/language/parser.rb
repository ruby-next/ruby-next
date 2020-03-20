# frozen_string_literal: true

require "parser/ruby27"

module RubyNext
  module Language
    class Builder < ::Parser::Builders::Default
      modernize
    end

    class << self
      def parser
        ::Parser::Ruby27.new(Builder.new).tap do |prs|
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
      end

      def parse_with_comments(source, file = "(string)")
        buffer = ::Parser::Source::Buffer.new(file).tap do |buffer|
          buffer.source = source
        end

        parser.parse_with_comments(buffer)
      end
    end
  end
end
