# source: https://github.com/ruby/spec/blob/master/core/enumerable/shared/find_all.rb

require_relative 'fixtures/classes'

describe "Enumerable#filter" do
  before :each do
    ScratchPad.record []
    @elements = (1..10).to_a
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns all elements for which the block is not false" do
    @numerous.filter {|i| i % 3 == 0 }.should == [3, 6, 9]
    @numerous.filter {|i| true }.should == @elements
    @numerous.filter {|i| false }.should == []
  end

  it "returns an enumerator when no block given" do
    @numerous.filter.should be_an_instance_of(Enumerator)
  end

  it "passes through the values yielded by #each_with_index" do
    [:a, :b].each_with_index.filter { |x, i| ScratchPad << [x, i] }
    ScratchPad.recorded.should == [[:a, 0], [:b, 1]]
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    multi.filter {|e| e == [3, 4, 5] }.should == [[3, 4, 5]]
  end

  it "mutate self when #filter!" do
    @elements.filter!(&:odd?).should == [1, 3, 5, 7, 9]
  end
end
