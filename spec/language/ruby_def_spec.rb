# source: https://github.com/ruby/ruby/blob/1997e10f6caeae49660ceb9342a01a4fd2efc788/test/ruby/test_syntax.rb#L1417

require_relative '../test_unit_to_mspec'

using TestUnitToMspec

eval <<~RUBY, binding, __FILE__, __LINE__
using TestUnitToMspec

class TestSyntaxMethodDefEndless < Test::Unit::TestCase
  def test_methoddef_endless
    assert_syntax_error('private def foo = 42', /unexpected '='/)
    assert_valid_syntax('private def foo() = 42')
    assert_valid_syntax('private def inc(x) = x + 1')
    assert_syntax_error('private def obj.foo = 42', /unexpected '='/)
    assert_valid_syntax('private def obj.foo() = 42')
    assert_valid_syntax('private def obj.inc(x) = x + 1')
    # TODO: right-hand assignment
    # eval('def self.inc(x) = x + 1 => @x')
    # assert_equal(:inc, @x)
  end
end
RUBY
