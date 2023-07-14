# frozen_string_literal: true

require_relative "../spec_helper"

$source_transform_enabled = false

RequireHooks.source_transform do |path, source|
  next unless $source_transform_enabled

  source ||= File.read(path)
  source.gsub(/cold/, "hot")
end

RequireHooks.source_transform do |path, source|
  next unless $source_transform_enabled
  next unless path =~ /fixtures\/freeze\.rb$/

  source ||= File.read(path)

  "# frozen_string_literal: true\n#{source}"
end

describe "require-hooks source_transform" do
  before do
    $source_transform_enabled = true
  end

  after do
    $source_transform_enabled = false
  end

  it "loads transformed source code" do
    load File.join(__dir__, "fixtures/freeze.rb")

    Freezy.weather.should == "hot"
  end

  it "loads original source code if transformers return nil" do
    $source_transform_enabled = false
    load File.join(__dir__, "fixtures/freeze.rb")

    Freezy.weather.should == "cold"
  end

  it "invoke all transformers" do
    load File.join(__dir__, "fixtures/freeze.rb")

    -> { Freezy.weather.sub!("c", "h") }.should raise_error(FrozenError)
  end
end
