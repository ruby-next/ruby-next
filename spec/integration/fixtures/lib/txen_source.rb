# frozen_string_literal: true

require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(rbnext_dir: ".rbnext_test", transpile: true)

require "txen/version"
require "txen/cards"
require "txen/game"

module Txen
  def self.call(*cards)
    cards.inject(0) do |acc, card|
      acc += Cards.call(card)
      return :failed if Game.failed?(acc)
      acc
    end
    :ok
  end
end
