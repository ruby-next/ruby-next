# source: https://github.com/ruby/ruby/blob/1997e10f6caeae49660ceb9342a01a4fd2efc788/test/ruby/test_syntax.rb#L1417

require_relative '../test_unit_to_mspec'

using TestUnitToMspec

eval <<~'RUBY', binding, __FILE__, __LINE__
using TestUnitToMspec
using RubyNext::Language::ClassEval

class TestSyntaxMethodDefEndless < Test::Unit::TestCase
  def test_methoddef_endless
    assert_valid_syntax('private def foo = 42')
    assert_valid_syntax('private def foo() = 42')
    assert_valid_syntax('private def inc(x) = x + 1')
    assert_valid_syntax('private def obj.foo = 42')
    assert_valid_syntax('private def obj.foo() = 42')
    assert_valid_syntax('private def obj.inc(x) = x + 1')
    k = Class.new do
      class_eval('def rescued(x) = raise("to be caught") rescue "instance #{x}"')
      class_eval('def self.rescued(x) = raise("to be caught") rescue "class #{x}"')
    end
    assert_equal("class ok", k.rescued("ok"))
    assert_equal("instance ok", k.new.rescued("ok"))
    error = /setter method cannot be defined in an endless method definition/
    assert_syntax_error('def foo=() = 42', error)
    assert_syntax_error('def obj.foo=() = 42', error)
    assert_syntax_error('def foo=() = 42 rescue nil', error)
    assert_syntax_error('def obj.foo=() = 42 rescue nil', error)
  end
end
RUBY
