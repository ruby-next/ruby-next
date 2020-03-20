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
        # NOTE: original source is changed to test runtime activation
        # (in the transpiled code you can should see 11)
        10
      end
    end
  end
end
