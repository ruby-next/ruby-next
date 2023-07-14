# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

if defined?(Warning) && Warning.respond_to?(:[]=)
  Warning[:experimental] = false
end

begin
  require "pry-byebug"
rescue LoadError, NameError
end

begin
  require "dead_end"
rescue LoadError, NameError
end

class MSpecScript
  # Require related specs
  set :require, %w[
    spec/core/kernel/require_spec.rb
    spec/core/kernel/require_relative_spec.rb
    spec/core/kernel/load_spec.rb
    spec/require-hooks
  ]
end

require "require-hooks/setup"

counter = 0

RequireHooks.around_load do |path, &block|
  next block.call unless path =~ %r{spec/core/kernel/[^/]+_spec.rb$}
  counter += 1
  block.call
end

post_counter = 0

RequireHooks.around_load do |path, &block|
  next block.call unless path =~ %r{spec/core/kernel/shared}

  block.call.tap do
    post_counter += 1
  end
end

if ARGV.join.include?(":require")
  at_exit do
    raise "Total spec files required must be 3, got #{counter}" unless counter == 3
    raise "Total shared files required must be 2, got #{post_counter}" unless post_counter == 2
  end
end
