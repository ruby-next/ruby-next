# frozen_string_literal: true

module RubyNext
  module Language
    module PacoParsers
      class Base
        include Paco

        def parse(io)
          default.parse(io)
        end

        private

        def anything_between(left, right)
          seq(
            left,
            many(not_followed_by(right).bind { any_char }).join,
            right
          ).join
        end

        def starting_string(str)
          index.bind do |index|
            (index.column > 1) ? failed("1 column") : string(str)
          end
        end
      end
    end
  end
end
