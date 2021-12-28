# frozen_string_literal: true

module RubyNext
  module Language
    module PacoParsers
      class StringLiterals < Base
        PAIRS = {"[" => "]", "{" => "}", "<" => ">"}.freeze

        def default
          alt(
            single_quoted,
            double_quoted,
            external_cmd_exec,
            quoted,
            quoted_expanded
          )
          # heredoc,
          # heredoc_expanded
        end

        def quoted
          seq(
            string("%q"),
            any_char.bind do |char|
              end_symbol = string(PAIRS[char] || char)
              escapable_string(succeed(char), end_symbol)
            end
          ).join
        end

        def single_quoted
          escapable_string(string("'"))
        end

        # TODO: add interpolation
        def quoted_expanded
          seq(
            alt(string("%Q"), string("%")),
            any_char.bind do |char|
              end_symbol = string(PAIRS[char] || char)
              escapable_string(succeed(char), end_symbol)
            end
          ).join
        end

        # TODO: add interpolation
        def external_cmd_exec
          escapable_string(string("`"))
        end

        # TODO: add interpolation
        def double_quoted
          escapable_string(string('"'))
        end

        def escapable_string(left, right = nil)
          right ||= left
          seq(
            left,
            many(
              alt(
                seq(string("\\"), right),
                not_followed_by(right).bind { any_char }
              )
            ).join,
            right
          ).join
        end
      end
    end
  end
end
