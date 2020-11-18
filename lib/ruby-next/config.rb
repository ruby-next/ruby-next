# frozen_string_literal: true

module RubyNext
  # Mininum Ruby version supported by RubyNext
  MIN_SUPPORTED_VERSION = Gem::Version.new("2.2.0")

  # Where to store transpiled files (relative from the project LOAD_PATH, usually `lib/`)
  RUBY_NEXT_DIR = ".rbnext"

  # Defines last minor version for every major version
  LAST_MINOR_VERSIONS = {
    2 => 8, # 2.8 is required for backward compatibility: some gems already uses it
    3 => 0
  }.freeze

  LATEST_VERSION = [3, 0].freeze

  class << self
    # TruffleRuby claims it's 2.7.2 compatible but...
    if defined?(TruffleRuby) && ::RUBY_VERSION =~ /^2\.7/
      def current_ruby_version
        "2.6.5"
      end
    else
      def current_ruby_version
        ::RUBY_VERSION
      end
    end

    def next_ruby_version(version = current_ruby_version)
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
end
