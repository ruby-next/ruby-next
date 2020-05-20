# frozen_string_literal: true

require_relative '../spec_helper'

describe "refined patches" do
  it "activates only unsupported patches" do
    next skip unless RubyNext::Utils.refine_modules?

    ruby_version = Gem::Version.new(RUBY_VERSION)

    activated_patches = RubyNext::Core.patches.refined.values.flatten.uniq

    incorrect_patches = activated_patches.select { |patch| Gem::Version.new(patch.version) <= ruby_version }

    incorrect_patches.map(&:name).should == []
  end
end
