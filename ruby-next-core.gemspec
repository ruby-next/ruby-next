# frozen_string_literal: true

require_relative "lib/ruby-next/version"

Gem::Specification.new do |s|
  s.name = "ruby-next-core"
  s.version = RubyNext::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/palkan/ruby-next"
  s.summary = "Ruby Next core functionality"
  s.description = %(
    Ruby Next Core is a zero deps version of Ruby Next meant to be used
    as as dependency in your gems.

    It contains all the polyfills and utility files but doesn't require transpiler
    dependencies to be install.
  )

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/ruby-next/ruby-next/issues",
    "changelog_uri" => "https://github.com/ruby-next/ruby-next/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/ruby-next/ruby-next/blob/master/README.md",
    "homepage_uri" => "http://github.com/ruby-next/ruby-next",
    "source_code_uri" => "http://github.com/ruby-next/ruby-next"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  s.required_ruby_version = ">= 2.3.0"

  s.require_paths = ["lib"]

  s.executables = ["ruby-next"]

  s.add_development_dependency "ruby-next-parser", ">= 2.8.0.9"
  s.add_development_dependency "unparser", ">= 0.4.7"
end
