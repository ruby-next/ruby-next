# frozen_string_literal: true

module RubyNext
  module Language
    module PacoParsers
      class StringLiterals < Base
        PAIRS = {"[" => "]", "{" => "}", "<" => ">"}.freeze

        def default
          all_strings.fmap do |result|
            reduce_tokens(result.flatten)
          end
        end

        def all_strings
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
          )
        end

        def single_quoted
          escapable_string(string("'"))
        end

        def quoted_expanded
          seq(
            alt(string("%Q"), string("%")),
            any_char.bind do |char|
              end_symbol = string(PAIRS[char] || char)
              escapable_string(succeed(char), end_symbol, interpolate: true)
            end
          )
        end

        def external_cmd_exec
          escapable_string(string("`"), interpolate: true)
        end

        def double_quoted
          escapable_string(string('"'), interpolate: true)
        end

        def escapable_string(left, right = nil, interpolate: false)
          right ||= left
          seq(
            left,
            many(
              alt(
                *[
                  seq(string("\\"), right).fmap { [:literal, _1] },
                  interpolate ? seq(
                    string('#{'),
                    lazy { alt(balanced("{", "}"), many(none_of("}"))) },
                    string("}")
                  ) : nil,
                  not_followed_by(right).bind { any_char }.fmap { [:literal, _1] }
                ].compact
              )
            ),
            right
          )
        end

        private

        def balanced(l, r)
          left = string(l)
          right = string(r)

          many(
            alt(
              seq(
                left,
                lazy { balanced(l, r) },
                right
              ),
              not_followed_by(right).bind { alt(all_strings, any_char) }
            )
          )
        end

        def reduce_tokens(tokens)
          state = :literal

          tokens.each_with_object([]) do |v, acc|
            if v == :literal
              acc << [:literal, +""] unless state == :literal
              state = :next_literal
              next acc
            end

            if state == :next_literal
              state = :literal
              acc.last[1] << v
              next acc
            end

            if state == :literal
              acc << [:code, +""]
            end

            state = :code
            acc.last[1] << v
          end
        end
      end
    end
  end
end
