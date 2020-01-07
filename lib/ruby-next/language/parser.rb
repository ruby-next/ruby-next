# frozen_string_literal: true

require "parser/ruby27"

module RubyNext
  module Language
    class Builder < ::Parser::Builders::Default
      modernize
    end

    class << self
      def parser
        ::Parser::Ruby27.new(Builder.new)
      end

      def parse(source, file = "(string)")
        buffer = ::Parser::Source::Buffer.new(file).tap do |buffer|
          buffer.source = source
        end
        parser.parse(buffer)
      end
    end
  end
end
