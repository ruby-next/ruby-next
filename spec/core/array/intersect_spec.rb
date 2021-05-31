require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Array#intersect?" do
  it "returns if there is intersection" do
    [].intersect?([]).should == false
    [1, 2].intersect?([]).should == false
    [].intersect?([1, 2]).should == false
    [ 1, 3, 5 ].intersect?([ 1, 2, 3 ]).should == true
    [ nil ].intersect?([ nil ]).should == true
  end

  it "does not modify the original Array" do
    a = [1, 1, 3, 5]
    a.intersect?([1, 2, 3]).should == true
    a.should == [1, 1, 3, 5]
  end

  it "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.intersect?(empty).should == true

    ArraySpecs.recursive_array.intersect?([]).should == false
    [].intersect?(ArraySpecs.recursive_array).should == false

    ArraySpecs.recursive_array.intersect?(ArraySpecs.recursive_array).should == true
  end

  it "tries to convert the passed argument to an Array using #to_ary" do
    obj = mock('[1,2,3]')
    obj.should_receive(:to_ary).and_return([1, 2, 3])
    [1, 2].intersect?(obj).should == true
  end

  it "determines equivalence between elements in the sense of eql?" do
    not_supported_on :opal do
      [5.0, 4.0].intersect?([5, 4]).should == false
    end

    str = "x"
    [str].intersect?([str.dup]).should == true

    obj1 = mock('1')
    obj2 = mock('2')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj1.should_receive(:eql?).at_least(1).and_return(true)
    obj2.stub!(:eql?).and_return(true)

    [obj1].intersect?([obj2]).should == true
    [obj1, obj1, obj2, obj2].intersect?([obj2]).should == true

    obj1 = mock('3')
    obj2 = mock('4')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj1.should_receive(:eql?).at_least(1).and_return(false)

    [obj1].intersect?([obj2]).should == false
    [obj1, obj1, obj2, obj2].intersect?([obj2]).should == true
  end

  it "does not call to_ary on array subclasses" do
    [5, 6].intersect?(ArraySpecs::ToAryArray[1, 2, 5, 6]).should == true
  end

  it "properly handles an identical item even when its #eql? isn't reflexive" do
    x = mock('x')
    x.stub!(:hash).and_return(42)
    x.stub!(:eql?).and_return(false) # Stubbed for clarity and latitude in implementation; not actually sent by MRI.

    [x].intersect?([x]).should == true
  end
end
