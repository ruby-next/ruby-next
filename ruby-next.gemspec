# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby-next/version"

Gem::Specification.new do |s|
  s.name = "ruby-next"
  s.version = RubyNext::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/palkan/ruby-next"
  s.summary = "Make older Rubies quack like edge Ruby"
  s.description = %(
    Coming soon.
  )

  s.license = "MIT"

  s.files = `git ls-files README.md LICENSE.txt`.split
  s.required_ruby_version = ">= 2.5.0"

  s.require_paths = ["lib"]

  s.executables = ["ruby-next"]

  s.add_development_dependency "parser", "~> 2.6.3.101"
  s.add_development_dependency "unparser", "~> 0.4.5"
end
