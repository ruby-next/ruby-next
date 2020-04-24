# frozen_string_literal: true

require_relative '../test_unit_to_mspec'

using TestUnitToMspec

describe "custom tests for endless method" do
  class CustomEndlessDefSpec
  end

  it "with pattern matching" do
    a = Class.new(CustomEndlessDefSpec) do
      def foo(val) =
        case val
        in bar:
          bar
        in baz:
          baz
        end
    end

    a.new.foo(bar: 1).should == 1
    a.new.foo(baz: "b").should == "b"
  end

  it "with args forwarding" do
    a = Class.new(CustomEndlessDefSpec)
    a.class_eval do
      def self.moo(word, num:)
        word * num
      end

      def self.foo(...) = moo(...) + moo(...)
    end

    a.foo("meow", num: 2).should == "meow" * 4
  end
end
