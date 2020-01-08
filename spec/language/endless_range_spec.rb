# source: https://developer.squareup.com/blog/rubys-new-infinite-range-syntax-0/

using RubyNext::Language::KernelEval

describe "endless range 1.." do
  it "as index" do
    [1, 2, 3][1..].should == [2, 3]
  end

  it "as arg" do
    [:a, :b, :c].zip(42..).should == [[:a, 42], [:b, 43], [:c, 44]]
  end

  it "with open end" do
    %w(a b c d)[2...].should == %w(c d)
  end

  it "in case" do
    eval(%q{
      case 2022
      when(2030..)
        :mysterious_future
      when(2020..)
        :twenties
      when(2010...)
        :nowish
      else
        :ancient_past
      end
    }).should == :twenties
  end
end
