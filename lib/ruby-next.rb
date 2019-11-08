# frozen_string_literal: true

require "ruby-next/version"

module RubyNext
  # Mininum Ruby version supported by RubyNext
  MIN_SUPPORTED_VERSION = Gem::Version.new("2.5.0")

  # Where to store transpiled files (relative from the project LOAD_PATH, usually `lib/`)
  RUBY_NEXT_DIR = ".rbnext"

  require_relative "ruby-next/core"
end
