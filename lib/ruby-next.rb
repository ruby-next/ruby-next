# frozen_string_literal: true

require "ruby-next/version"

module RubyNext
  # Mininum Ruby version supported by RubyNext
  MIN_SUPPORTED_VERSION = Gem::Version.new("2.2.0")

  # Where to store transpiled files (relative from the project LOAD_PATH, usually `lib/`)
  RUBY_NEXT_DIR = ".rbnext"

  # Defines last minor version for every major version
  LAST_MINOR_VERSIONS = {
    2 => 8
  }.freeze

  LATEST_VERSION = [2, 8].freeze

  class << self
    def next_version(version = RUBY_VERSION)
      major, minor = Gem::Version.new(version).segments.map(&:to_i)

      return if major >= LATEST_VERSION.first && minor >= LATEST_VERSION.last

      nxt =
        if LAST_MINOR_VERSIONS[major] == minor
          "#{major + 1}.0.0"
        else
          "#{major}.#{minor + 1}.0"
        end

      Gem::Version.new(nxt)
    end
  end

  require_relative "ruby-next/core"
  require_relative "ruby-next/core_ext" if RubyNext::Core.core_ext?
  require_relative "ruby-next/logging"
end
