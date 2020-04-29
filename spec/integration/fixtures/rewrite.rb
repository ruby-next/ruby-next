# frozen_string_literal: true

module Eternal
  def self.call
    case 4
    in (1..)
      true
    else
      false
    end => x

    !x
  end

  # add a method which has different layout in parse/unparse
  def self.hash() =
    {
      a: 1,
      b: 2
    }
end
