# frozen_string_literal: true

require_relative "../support/command_testing"

# rubocop:disable Lint/InterpolationCheck
describe "IRB" do
  before do
    @irb_dir = File.join(__dir__, "fixtures", "irb")
  end

  it "loads RC file" do
    next skip if !defined?(IRB::VERSION) || Gem::Version.new(IRB::VERSION) < Gem::Version.new("1.2.4")

    run_irb("--echo", input: %w[irb_info], chdir: @irb_dir) do |_status, output, _err|
      output.should include("spec/integration/fixtures/irb/.irbrc\n")
    end
  end

  if ENV["CORE_EXT"] == "false"
    it "supports refinements" do
      next skip if Gem::Version.new(::RubyNext.current_ruby_version) >= Gem::Version.new("3.1")

      # Array#intersect? added in 3.1:
      input = [
        "a = [1, 2, 3]",
        "b = [2, 3]",
        'puts "Intersect: #{a.intersect?(b)}"'
      ]

      run_irb(input: input, chdir: @irb_dir) do |_status, output, _err|
        output.should include("Intersect: true")
      end

      run_irb("-f", input: input, chdir: @irb_dir) do |_status, output, _err|
        output.should include("NoMethodError")
        output.should_not include("Intersect: true")
      end
    end
  end

  it "supports edge syntax" do
    input = [
      "config = {db: {user: 'admin', password: 'abc123'}}",
      "config => {db: {user:}}",
      'puts "User: #{user}"'
    ]

    run_irb(input: input, chdir: @irb_dir) do |_status, output, _err|
      output.should include("User: admin")
    end
  end

  it "works when loaded via -r" do
    input = [
      "config = {db: {user: 'admin', password: 'abc123'}}",
      "config => {db: {user:}}",
      'puts "User: #{user}"'
    ]

    run_irb("-f -ruby-next/irb", input: input, chdir: @irb_dir) do |_status, output, _err|
      output.should include("User: admin")
    end
  end

  it "supports multi-line input" do
    input = [
      "def foo(...)",
      "bar(...)",
      "end",
      "def bar(x); x; end",
      'puts "Foo: #{foo(42)}"'
    ]

    run_irb(input: input, chdir: @irb_dir) do |_status, output, _err|
      output.should include("Foo: 42")
    end

    input = [
      "def foo(a,b,",
      "c,d)",
      "]"
    ]

    run_irb(input: input, chdir: @irb_dir) do |_status, output, _err|
      output.should include("SyntaxError")
    end
  end
end
# rubocop:enable Lint/InterpolationCheck
