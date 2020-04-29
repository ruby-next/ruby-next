# source: https://github.com/ruby/ruby/blob/1997e10f6caeae49660ceb9342a01a4fd2efc788/test/ruby/test_syntax.rb#L1573

require_relative '../test_unit_to_mspec'

using TestUnitToMspec

eval <<~RUBY, binding, __FILE__, __LINE__
using TestUnitToMspec

class TestRightHandAssignment < Test::Unit::TestCase
  def test_rightward_assign
    assert_equal(1, eval("1 => a"))
    assert_equal([2,3], eval("13.divmod(5) => a,b; [a, b]"))
    assert_equal([2,3,2,3], eval("13.divmod(5) => a,b => c, d; [a, b, c, d]"))
    assert_equal(3, eval("1+2 => a"))
  end
end
RUBY
