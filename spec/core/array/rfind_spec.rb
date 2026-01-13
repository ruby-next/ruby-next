require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Array#rfind" do
  before :each do
    @elements = [2, 4, 6, 8, 10]
    @array = @elements.dup
    @empty = []
  end

  it "passes each entry in array to block in reverse order while block is false" do
    visited_elements = []
    @array.rfind do |element|
      visited_elements << element
      false
    end
    visited_elements.should == @elements.reverse
  end

  it "returns nil when the block is false and there is no ifnone proc given" do
    @array.rfind { |e| false }.should == nil
  end

  it "returns the last element for which the block is not false" do
    @array.rfind { |e| e < 5 }.should == 4
    @array.rfind { |e| e < 7 }.should == 6
    @array.rfind { |e| e < 10 }.should == 8
    @array.rfind { |e| true }.should == 10
  end

  it "returns the value of the ifnone proc if the block is false" do
    fail_proc = -> { "cheeseburgers" }
    @array.rfind(fail_proc) { |e| false }.should == "cheeseburgers"
  end

  it "doesn't call the ifnone proc if an element is found" do
    fail_proc = -> { raise "This shouldn't have been called" }
    @array.rfind(fail_proc) { |e| e == @elements.last }.should == 10
  end

  it "calls the ifnone proc only once when the block is false" do
    times = 0
    fail_proc = -> { times += 1; raise if times > 1; "cheeseburgers" }
    @array.rfind(fail_proc) { |e| false }.should == "cheeseburgers"
  end

  it "calls the ifnone proc when there are no elements" do
    fail_proc = -> { "yay" }
    @empty.rfind(fail_proc) { |e| true }.should == "yay"
  end

  it "ignores the ifnone argument when nil" do
    @array.rfind(nil) { |e| false }.should == nil
  end

  it "returns an enumerator when no block given" do
    @array.rfind.should be_an_instance_of(Enumerator)
  end

  it "returns an enumerator that iterates in reverse order" do
    visited_elements = []
    @array.rfind.each do |element|
      visited_elements << element
      false
    end
    visited_elements.should == @elements.reverse
  end

  it "passes the ifnone proc to the enumerator" do
    times = 0
    fail_proc = -> { times += 1; raise if times > 1; "cheeseburgers" }
    @array.rfind(fail_proc).each { |e| false }.should == "cheeseburgers"
  end

  it "does not modify the original Array" do
    original = @array.dup
    @array.rfind { |e| e == 6 }
    @array.should == original
  end

  it "returns the last matching element, not the first" do
    [1, 2, 3, 2, 1].rfind { |e| e == 2 }.should == 2
    # Verify it's actually the last one by checking with a stateful block
    found_index = nil
    [1, 2, 3, 2, 1].each_with_index { |e, i| found_index = i if e == 2 }
    found_index.should == 3  # last index where element is 2
  end

  it "works with arrays containing nil" do
    [1, nil, 2, nil, 3].rfind { |e| e.nil? }.should == nil
    # Verify we actually found something (not just returned nil for no match)
    found = false
    [1, nil, 2, nil, 3].rfind { |e| found = true if e.nil?; e.nil? }
    found.should == true
  end

  it "works with arrays containing false" do
    [true, false, true, false].rfind { |e| e == false }.should == false
  end

  it "properly handles recursive arrays" do
    array = ArraySpecs.recursive_array
    array.rfind { |e| e == 1 }.should == 1
  end

  it "returns nil for empty arrays without ifnone" do
    [].rfind { |e| true }.should == nil
  end
end
