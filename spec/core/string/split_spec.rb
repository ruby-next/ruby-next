# source: https://github.com/ruby/ruby/blob/master/spec/ruby/core/string/split_spec.rb

# NOTE: only 2.6 related specs are included

require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "String#split with String" do
  ruby_version_is "2.6" do
    it "yields each split substrings if a block is given" do
      a = []
      returned_object = "chunky bacon".split(" ") { |str| a << str.capitalize }

      returned_object.should == "chunky bacon"
      a.should == ["Chunky", "Bacon"]
    end

    describe "for a String subclass" do
      it "yields instances of the same subclass" do
        a = []
        StringSpecs::MyString.new("a|b").split("|") { |str| a << str }
        first, last = a

        first.should be_an_instance_of(StringSpecs::MyString)
        first.should == "a"

        last.should be_an_instance_of(StringSpecs::MyString)
        last.should == "b"
      end
    end
  end
end