# frozen_string_literal: true

module RubyNext
  module Language
    module PacoParsers
      class Comments < Base
        def default
          alt(
            line_comment,
            block_comment
          )
        end

        # Matches a Ruby line comment (from `#` till the end of the line)
        def line_comment
          anything_between(string("#"), end_of_line)
        end

        # Matches a Ruby block comment (from `=begin` till `=end`)
        def block_comment
          anything_between(starting_string("=begin"), starting_string("=end"))
        end
      end
    end
  end
end
