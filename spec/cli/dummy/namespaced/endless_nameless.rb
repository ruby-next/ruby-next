# frozen_string_literal: true

module Foreva
  def self.call
    (1..).each do |n|
      sleep n
    end
  end
end
