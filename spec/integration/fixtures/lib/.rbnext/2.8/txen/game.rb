# frozen_string_literal: true

module Txen
  module Game
    def self.failed?(num)
      (22...).cover?(num)
    end
  end
end
