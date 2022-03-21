# frozen_string_literal: true

module Eternal
  def self.call
    y =
      case 4
      in (1..)
        {status: true}
      in Array[*, 4, *]
        {status: true}
      else
        {status: false}
      end

    y => {status: Object => x}

    !x
  end

  # add a method which has different layout in parse/unparse
  def self.hash() =
    {
      a: 1,
      b: 2
    }

  # add lambda with rescue
  lambda do 1/0; rescue ZeroDivisionError; puts "1/0"; end # rubocop:disable Layout/SpaceAroundOperators
end
