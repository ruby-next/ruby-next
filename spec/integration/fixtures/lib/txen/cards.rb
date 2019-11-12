# frozen_string_literal: true

module Txen
  module Cards
    def self.call(id)
      case id
      in "2" | "3" | "4" | "5" | "6" | "7" | "9" | "10"
        id.to_i
      in "jack" | "queen" | "king"
        10
      in "ace"
        11
      end
    end
  end
end
