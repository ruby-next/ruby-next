# frozen_string_literal: true

require_relative "lib/ruby-next/version"

Gem::Specification.new do |s|
  s.name = "ruby-next"
  s.version = RubyNext::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/palkan/ruby-next"
  s.summary = "Make older Rubies quack like edge Ruby"
  s.description = %(
    Ruby Next is a collection of polyfills and a transpiler for supporting latest and upcoming edge CRuby features
    in older versions and alternative implementations (such as mruby, JRuby, Opal, Artichoke, RubyMotion, etc.).
  )

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/ruby-next/ruby-next/issues",
    "changelog_uri" => "https://github.com/ruby-next/ruby-next/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/ruby-next/ruby-next/blob/master/README.md",
    "homepage_uri" => "http://github.com/ruby-next/ruby-next",
    "source_code_uri" => "http://github.com/ruby-next/ruby-next"
  }

  s.license = "MIT"

  s.files = %w[README.md LICENSE.txt CHANGELOG.md]
  s.required_ruby_version = ">= 2.5.0"

  s.require_paths = ["lib"]

  s.add_dependency "ruby-next-core"
  s.add_dependency "ruby-next-parser", ">= 2.8.0.4"
  s.add_dependency "unparser", ">= 0.4.7"
end
