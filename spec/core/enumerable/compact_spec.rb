# source: https://github.com/ruby/spec/blob/master/core/enumerable/shared/find_all.rb

require_relative 'fixtures/classes'

describe "Enumerable#compact" do
  before :each do
    @elements = [false, 2, 3, nil, 5, nil, 7, nil, nil]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns all non-nil elements" do
    @numerous.compact.should == [false, 2, 3, 5, 7]
  end

  describe ".lazy" do
    it "returns non-nil elements" do
      [0, 1, nil, 2, false, 3, nil].to_enum.lazy.compact.force.should == [0, 1, 2, false, 3]
    end
  end
end
