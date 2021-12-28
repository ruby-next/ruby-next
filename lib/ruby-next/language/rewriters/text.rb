# frozen_string_literal: true

require "ruby-next/language/paco_parser"

module RubyNext
  module Language
    module Rewriters
      class Text < Abstract
        class Parser
          include Paco

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
            PacoParsers::Comments.new.default.fmap do |result|
              store << result
              "# A#{store.size}Я\n"
            end
          end

          def ruby_string
            PacoParsers::StringLiterals.new.default.fmap do |result|
              store << result
              "%|A#{store.size}Я|"
            end
          end

          def ruby_code
            any_char
          end

          def restore(source)
            source.gsub(/(?:\# |%\|)A(\d+)Я(?:\||\n)/m) do |*args|
              store[$1.to_i - 1]
            end
          end
        end

        def self.text?
          true
        end

        def rewrite(source)
          source
        end

        # Rewrite source code by ignoring string literals and comments
        def safe_rewrite(source)
          Parser.new.normalizing(source) do |normalized|
            rewrite(normalized)
          end
        end
      end
    end
  end
end
