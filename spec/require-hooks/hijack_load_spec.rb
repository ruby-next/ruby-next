# frozen_string_literal: true

require_relative "../spec_helper"

$hijack_load_enabled = false
$source_transform_enabled = false

RequireHooks.source_transform do |path, source|
  next unless $hijack_load_enabled
  next unless $source_transform_enabled
  next unless path =~ /fixtures\/freeze\.rb$/

  source ||= File.read(path)

  source.gsub(/cold/, "hot")
end

RequireHooks.hijack_load do |path, source|
  next unless $hijack_load_enabled
  next unless path =~ /fixtures\/freeze\.rb$/

  iseq =
    if source
      RubyVM::InstructionSequence.compile(source, path, path, 1, {frozen_string_literal: true})
    else
      RubyVM::InstructionSequence.compile_file(path, {frozen_string_literal: true})
    end

  iseq
end

RequireHooks.hijack_load do |path, source|
  next unless $hijack_load_enabled

  RubyVM::InstructionSequence.compile_file(path)
end

# rubocop:disable Lint/Void
describe "require-hooks hijack_load" do
  # TODO: add support for other Rubies
  next skip unless defined?(RubyVM::InstructionSequence)

  before do
    $source_transform_enabled = true
    $hijack_load_enabled = true
  end

  after do
    $source_transform_enabled = false
    $hijack_load_enabled = false
  end

  it "loads bytecode with the first hijack" do
    load File.join(__dir__, "fixtures/freeze.rb")

    Freezy.weather.should == "hot"
  end

  it "fallbacks to the next hijack if the first one skipped" do
    load File.join(__dir__, "fixtures/hi_jack.rb")

    HiJack.say.should == "yo"
    HiJack.say.sub!("yo", "hi").should == "hi"
  end

  it "loads original source code if no hijacks were invoked" do
    $source_transform_enabled = false
    $hijack_load_enabled = false

    load File.join(__dir__, "fixtures/freeze.rb")

    Freezy.weather.should == "cold"

    load File.join(__dir__, "fixtures/hi_jack.rb")

    HiJack.say.should == "yo"
  end

  it "reads source code if no transformations" do
    $source_transform_enabled = false
    load File.join(__dir__, "fixtures/freeze.rb")

    Freezy.weather.should == "cold"

    -> { Freezy.weather.sub!("c", "h") }.should raise_error(FrozenError)
  end
end
# rubocop:enable Lint/Void
