# frozen_string_literal: true

module RubyNext
  # Mininum Ruby version supported by RubyNext
  MIN_SUPPORTED_VERSION = Gem::Version.new("2.2.0")

  # Where to store transpiled files (relative from the project LOAD_PATH, usually `lib/`)
  RUBY_NEXT_DIR = ".rbnext"

  # Defines last minor version for every major version
  LAST_MINOR_VERSIONS = {
    2 => 8, # 2.8 is required for backward compatibility: some gems already uses it
    3 => 5
  }.freeze

  LATEST_VERSION = [3, 5].freeze

  # A virtual version number used for proposed features
  NEXT_VERSION = "1995.next.0"

  class << self
    # TruffleRuby claims its RUBY_VERSION to be X.Y while not supporting all the features
    # Currently (23.x), it still doesn't support pattern matching, although claims to be "like 3.1".
    # So, we fallback to 2.6.5 (since we cannot use 2.7).
    # TruffleRuby 24.x seems to support pattern matching.
    if defined?(TruffleRuby)
      def current_ruby_version
        if RUBY_ENGINE_VERSION >= "24.0.0"
          "3.1.0"
        else
          "2.6.5"
        end
      end
    else
      def current_ruby_version
        ::RUBY_VERSION
      end
    end

    # Returns true if we want to use edge syntax
    def edge_syntax?
      %w[y true 1].include?(ENV["RUBY_NEXT_EDGE"])
    end

    def proposed_syntax?
      %w[y true 1].include?(ENV["RUBY_NEXT_PROPOSED"])
    end

    def next_ruby_version(version = current_ruby_version)
      return if version == Gem::Version.new(NEXT_VERSION)

      major, minor = Gem::Version.new(version).segments.map(&:to_i)

      return Gem::Version.new(NEXT_VERSION) if major >= LATEST_VERSION.first && minor >= LATEST_VERSION.last

      nxt =
        if LAST_MINOR_VERSIONS[major] == minor
          "#{major + 1}.0.0"
        else
          "#{major}.#{minor + 1}.0"
        end

      Gem::Version.new(nxt)
    end

    # Load transpile settings from the RC file (nextify command flags)
    def load_from_rc(path = ".rbnextrc")
      return unless File.exist?(path)

      require "yaml"

      args = YAML.load_file(path)&.fetch("nextify", "")&.lines&.flat_map { |line| line.chomp.split(/\s+/) }

      ENV["RUBY_NEXT_EDGE"] ||= "true" if args.delete("--edge")
      ENV["RUBY_NEXT_PROPOSED"] ||= "true" if args.delete("--proposed")
      ENV["RUBY_NEXT_TRANSPILE_MODE"] ||= "rewrite" if args.delete("--transpile-mode=rewrite")
      ENV["RUBY_NEXT_TRANSPILE_MODE"] ||= "ast" if args.delete("--transpile-mode=ast")
    end
  end

  load_from_rc
end
