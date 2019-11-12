module Txen
  module Game
    def self.failed?(num)
      (22..::Float::INFINITY).cover?(num)
    end
  end
end