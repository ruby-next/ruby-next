# source: https://github.com/ruby/ruby/blob/master/test/ruby/test_syntax.rb#L1418

require_relative '../test_unit_to_mspec'

using RubyNext::Language::KernelEval
using TestUnitToMspec

describe "numbered parameters: -> { _1 + _2 }" do
  it "block" do
    assert_equal(3, eval('[1,2].yield_self {_1+_2}'))
  end

  it "block + interpolation" do
    assert_equal("12", eval('[1,2].yield_self {"#{_1}#{_2}"}'))
  end

  it "block one param" do
    assert_equal([1, 2], eval('[1,2].yield_self {_1}'))
  end

  it "lambda" do
    assert_equal(3, eval('->{_1+_2}.call(1,2)'))
  end

  it "composed lambdas" do
    assert_equal(4, eval('->(a=->{_1}){a}.call.call(4)'))
  end

  it "composed lambdas 2" do
    assert_equal(5, eval('-> a: ->{_1} {a}.call.call(5)'))
  end
end
