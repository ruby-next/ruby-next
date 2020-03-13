# frozen_string_literal: true

module Test
  def self.call
    # Add some code to be transpiled to make sure
    # we transform it
    case 1
      in Integer
        puts "Not refined: #{"1".to_i}" #=> Not refined: 1
    end
  end
end
