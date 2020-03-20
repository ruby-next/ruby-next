# frozen_string_literal: true

module Ref
  refine String do
    def to_i
      0
    end
  end
end

using Ref

module Test
  # Add some code to be transpiled to make sure
  # we transform it
  case 1
    in Integer
      puts "Refined: #{"1".to_i}" #=> Refined: 0
  end
end
