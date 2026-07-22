# frozen_string_literal: true

require "ruby-next/language/paco_parser"

module RubyNext
  module Language
    module Rewriters
      class Text < Abstract
        using RubyNext

        class Normalizer < PacoParsers::Base
          attr_reader :store

          def initialize
            @store = []
          end

          def normalizing(source)
            many(
              alt(
                ruby_comment,
                ruby_string,
                ruby_code
              )
            ).parse(source, with_callstack: true)
              .then(&:join)
              .then do
                if block_given?
                  yield _1
                else
                  _1
                end
              end
              .then do |new_source|
              restore(new_source)
            end
          end

          def ruby_comment
            parse_comments.fmap do |result|
              store << result
              "# A#{store.size}Я\n"
            end
          end

          def ruby_string
            parse_strings.fmap do |result|
              result.each_with_object([]) do |(type, str), acc|
                if type == :literal
                  store << str
                  acc << "_A#{store.size}Я_"
                else
                  acc << str
                end
                acc
              end.join
            end
          end

          def ruby_code
            any_char
          end

          def restore(source)
            source.gsub(/(?:\# |_)A(\d+)Я(?:_|\n)/m) do |*args|
              store[$1.to_i - 1]
            end
          end

          def parse_comments
            memoize { PacoParsers::Comments.new.default }
          end

          def parse_strings
            memoize { PacoParsers::StringLiterals.new.default }
          end
        end

        # Base class for rewriting parsers which adds the #track! method
        class PacoParser < PacoParsers::Base
          attr_reader :rewriter, :context

          def initialize(rewriter, context)
            @rewriter = rewriter
            @context = context
          end

          def track!
            context.track!(rewriter)
          end
        end

        class << self
          def parser(&block)
            @paco_parser = Class.new(PacoParser, &block)
          end

          def paco_parser
            return @paco_parser if @paco_parser

            superclass.paco_parser if superclass.respond_to?(:paco_parser)
          end

          def text?
            true
          end
        end

        # Rewrite source code by ignoring string literals and comments
        def rewrite(source)
          Normalizer.new.normalizing(source) do |normalized|
            safe_rewrite(normalized).tap do |rewritten|
              context.track!(self) if rewritten != normalized
            end
          end
        end

        def safe_rewrite(source)
          source
        end

        private

        def parse(source)
          parser_class = self.class.paco_parser
          raise "No parser defined for #{self.class}" unless parser_class

          paco_parser = self.class.paco_parser.new(self, context)
          paco_parser.parse(source)
        end
      end
    end
  end
end
