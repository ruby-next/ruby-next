# source: none

require_relative 'fixtures/method_reference'

describe "method reference .:" do
  it "returns a Method" do
    m = MethodReference.:add
    m.class.should == Method
  end

  it "works" do
    MethodReference.:add.call(2, 3).should == 5
  end

  it "works with to_proc" do
    [-1, 2, -3].select(&MethodReference.:positive?).should == [2]
  end
end
