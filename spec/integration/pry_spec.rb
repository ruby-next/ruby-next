# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../test_unit_to_mspec"

require "pry"

using TestUnitToMspec

class MockPryDriver
  class << self
    attr_accessor :pry_instance, :last_result

    def start(options)
      @pry_instance = Pry.new(options)
    end

    def read(code)
      pry_instance.eval(code)
      @last_result = pry_instance.output.string
      pry_instance.output.reopen # flush
    end

    def last_command
      pry_instance.input_ring.to_a.last
    end
  end
end

describe "pry" do
  before do
    Pry.configure do |config|
      config.rc_file = File.join(__dir__, "fixtures", "pry", ".pryrc")
      config.print = ->(output, value, _pry_instance) { output << value }
    end

    Pry.initial_session_setup
  end

  before :each do
    Pry.start(nil, driver: MockPryDriver, input: StringIO.new, output: StringIO.new)
  end

  if ENV["CORE_EXT"] == "false"
    it "supports refinements" do
      # Hash#merge added in 2.6:
      MockPryDriver.read('h1 = { "a" => 100, "b" => 200 }')
      MockPryDriver.read('h2 = { "b" => 254, "c" => 300 }')
      MockPryDriver.read("h1.merge(h2)")
      assert_equal MockPryDriver.last_result, {"a" => 100, "b" => 254, "c" => 300}.inspect

      # Array#intersection added in 2.7:
      MockPryDriver.read("[0, 1, 2, 3].intersection([0, 1, 2], [0, 1, 3])")
      assert_equal MockPryDriver.last_result, "[0, 1]"

      # Hash#except added in 3.0:
      MockPryDriver.read("hash = { a: true, b: false, c: nil }")
      MockPryDriver.read("hash.except(:a, :b)")
      assert_equal MockPryDriver.last_result, {c: nil}.inspect

      next skip if RUBY_VERSION >= "3.0.0"

      file = File.join(__dir__, "fixtures", "pry", "example.rb")
      MockPryDriver.read("load_without_ruby_next('#{file}')")
      assert_match "NoMethodError", MockPryDriver.last_result
    end
  end

  it "keeps local variables defined in .pryrc" do
    MockPryDriver.read("hello")
    assert_equal MockPryDriver.last_result, "world"
  end

  it "supports edge syntax" do
    MockPryDriver.read("config = {db: {user: 'admin', password: 'abc123'}}")
    MockPryDriver.read("config => {db: {user:}}")
    MockPryDriver.read("user")
    assert_equal MockPryDriver.last_result, "admin"
  end

  it "supports multi-line input" do
    MockPryDriver.read("def foo(...)")
    MockPryDriver.read("bar(...)")
    MockPryDriver.read("end")
    MockPryDriver.read("def bar(x); x; end")
    MockPryDriver.read("foo(42)")
    assert_equal MockPryDriver.last_result, "42"

    MockPryDriver.read("def foo(a,b,")
    MockPryDriver.read("c,d)")
    MockPryDriver.read("]")
    assert_match "SyntaxError", MockPryDriver.last_result
  end

  it "keeps valid history" do
    line = "{b: 0, c: 1} => {b:}"
    MockPryDriver.read(line)
    assert_equal MockPryDriver.last_command.chomp, line
  end
end
