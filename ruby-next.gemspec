# frozen_string_literal: true

require_relative "lib/ruby-next/version"

Gem::Specification.new do |s|
  s.name = "ruby-next"
  s.version = RubyNext::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "https://github.com/ruby-next/ruby-next"
  s.summary = "Make older Rubies quack like edge Ruby"
  s.description = %(
    Ruby Next is a collection of polyfills and a transpiler for supporting latest and upcoming edge CRuby features
    in older versions and alternative implementations (such as mruby, JRuby, Opal, Artichoke, RubyMotion, etc.).
  )

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/ruby-next/ruby-next/issues",
    "changelog_uri" => "https://github.com/ruby-next/ruby-next/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/ruby-next/ruby-next/blob/master/README.md",
    "homepage_uri" => "https://github.com/ruby-next/ruby-next",
    "source_code_uri" => "https://github.com/ruby-next/ruby-next"
  }

  s.license = "MIT"

  s.files = %w[README.md LICENSE.txt CHANGELOG.md]
  s.required_ruby_version = ">= 2.2.0"

  s.require_paths = ["lib"]

  s.add_dependency "ruby-next-core", RubyNext::VERSION
  s.add_dependency "ruby-next-parser", ">= 3.1.1.0"
  s.add_dependency "require-hooks", "~> 0.2"
  s.add_dependency "unparser", "~> 0.6.0"
  s.add_dependency "paco", "~> 0.2"
end
