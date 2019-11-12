# source: https://github.com/ruby/spec/blob/master/core/array/shared/union.rb 

# NOTE: `send(@method)` was changed to the direct `then` call to make it work in JRuby.
#       See https://github.com/jruby/jruby/issues/5945
describe :array_binary_union, shared: true do
  it "returns an array of elements that appear in either array (union)" do
    [].union([]).should == []
    [1, 2].union([]).should == [1, 2]
    [].union([1, 2]).should == [1, 2]
    [ 1, 2, 3, 4 ].union([ 3, 4, 5 ]).should == [1, 2, 3, 4, 5]
  end

  it "creates an array with no duplicates" do
    [ 1, 2, 3, 1, 4, 5 ].union([ 1, 3, 4, 5, 3, 6 ]).should == [1, 2, 3, 4, 5, 6]
  end

  it "creates an array with elements in order they are first encountered" do
    [ 1, 2, 3, 1 ].union([ 1, 3, 4, 5 ]).should == [1, 2, 3, 4, 5]
  end

  it "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.union(empty).should == empty

    array = ArraySpecs.recursive_array
    array.union([]).should == [1, 'two', 3.0, array]
    [].union(array).should == [1, 'two', 3.0, array]
    array.union(array).should == [1, 'two', 3.0, array]
    array.union(empty).should == [1, 'two', 3.0, array, empty]
  end

  it "tries to convert the passed argument to an Array using #to_ary" do
    obj = mock('[1,2,3]')
    obj.should_receive(:to_ary).and_return([1, 2, 3])
    [0].union(obj).should == ([0] | [1, 2, 3])
  end

  # MRI follows hashing semantics here, so doesn't actually call eql?/hash for Fixnum/Symbol
  it "acts as if using an intermediate hash to collect values" do
    not_supported_on :opal do
      [5.0, 4.0].union([5, 4]).should == [5.0, 4.0, 5, 4]
    end

    str = "x"
    [str].union([str.dup]).should == [str]

    obj1 = mock('1')
    obj2 = mock('2')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj2.should_receive(:eql?).at_least(1).and_return(true)

    [obj1].union([obj2]).should == [obj1]
    [obj1, obj1, obj2, obj2].union([obj2]).should == [obj1]

    obj1 = mock('3')
    obj2 = mock('4')
    obj1.stub!(:hash).and_return(0)
    obj2.stub!(:hash).and_return(0)
    obj2.should_receive(:eql?).at_least(1).and_return(false)

    [obj1].union([obj2]).should == [obj1, obj2]
    [obj1, obj1, obj2, obj2].union([obj2]).should == [obj1, obj2]
  end

  it "does not return subclass instances for Array subclasses" do
    ArraySpecs::MyArray[1, 2, 3].union([]).should be_an_instance_of(Array)
    ArraySpecs::MyArray[1, 2, 3].union(ArraySpecs::MyArray[1, 2, 3]).should be_an_instance_of(Array)
    [].union(ArraySpecs::MyArray[1, 2, 3]).should be_an_instance_of(Array)
  end

  it "does not call to_ary on array subclasses" do
    [1, 2].union(ArraySpecs::ToAryArray[5, 6]).should == [1, 2, 5, 6]
  end

  it "properly handles an identical item even when its #eql? isn't reflexive" do
    x = mock('x')
    x.stub!(:hash).and_return(42)
    x.stub!(:eql?).and_return(false) # Stubbed for clarity and latitude in implementation; not actually sent by MRI.

    [x].union([x]).should == [x]
  end
end
