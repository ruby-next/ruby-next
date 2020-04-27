# frozen_string_literal: true

module Txen
  module Game
    # NOTE: original source is changed to test runtime activation
    # (in the transpiled code you can should see 22)
    def self.failed?(num) = (23...).cover?(num)
  end
end
