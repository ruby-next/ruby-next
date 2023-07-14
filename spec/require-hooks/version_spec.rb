# frozen_string_literal: true

require_relative "../spec_helper"

describe "require-hooks version" do
  it "must be the same as ruby-next version" do
    require "require-hooks/version"

    ruby_next_version = Gem::Version.new(::RubyNext::VERSION)
    require_hooks_version = Gem::Version.new(::RequireHooks::VERSION)

    ruby_next_version.should == require_hooks_version
  end
end
