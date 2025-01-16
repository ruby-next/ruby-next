# frozen_string_literal: true

require_relative "lib/ruby-next/version"

Gem::Specification.new do |s|
  s.name = "ruby-next-core"
  s.version = RubyNext::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "https://github.com/ruby-next/ruby-next"
  s.summary = "Ruby Next core functionality"
  s.description = %(
    Ruby Next Core is a zero deps version of Ruby Next meant to be used
    as as dependency in your gems.

    It contains all the polyfills and utility files but doesn't require transpiler
    dependencies to be install.
  )

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/ruby-next/ruby-next/issues",
    "changelog_uri" => "https://github.com/ruby-next/ruby-next/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/ruby-next/ruby-next/blob/master/README.md",
    "homepage_uri" => "https://github.com/ruby-next/ruby-next",
    "source_code_uri" => "https://github.com/ruby-next/ruby-next",
    "funding_uri" => "https://github.com/sponsors/palkan"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/ruby-next/**/*") +
    Dir.glob("lib/uby-next/**/*") +
    Dir.glob("lib/.rbnext/**/*") +
    Dir.glob("bin/**/*") +
    %w[lib/ruby-next.rb lib/uby-next.rb] +
    %w[README.md LICENSE.txt CHANGELOG.md]

  s.required_ruby_version = ">= 2.2.0"

  s.require_paths = ["lib"]

  s.executables = ["ruby-next"]

  s.add_development_dependency "require-hooks", "~> 0.2"
  s.add_development_dependency "ruby-next-parser", ">= 3.4.0.2"
  s.add_development_dependency "unparser", "~> 0.6.0"
  s.add_development_dependency "paco", "~> 0.2"
end
