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

  # def test_methoddef_endless_command
  #   assert_valid_syntax('def foo = puts "Hello"')
  #   assert_valid_syntax('def foo() = puts "Hello"')
  #   assert_valid_syntax('def foo(x) = puts x')
  #   assert_valid_syntax('def obj.foo = puts "Hello"')
  #   assert_valid_syntax('def obj.foo() = puts "Hello"')
  #   assert_valid_syntax('def obj.foo(x) = puts x')
  #   k = Class.new do
  #     class_eval('def rescued(x) = raise "to be caught" rescue "instance #{x}"')
  #     class_eval('def self.rescued(x) = raise "to be caught" rescue "class #{x}"')
  #   end
  #   assert_equal("class ok", k.rescued("ok"))
  #   assert_equal("instance ok", k.new.rescued("ok"))
  #   # Current technical limitation: cannot prepend "private" or something for command endless def
  #   error = /syntax error, unexpected string literal/
  #   error2 = /syntax error, unexpected local variable or method/
  #   assert_syntax_error('private def foo = puts "Hello"', error)
  #   assert_syntax_error('private def foo() = puts "Hello"', error)
  #   assert_syntax_error('private def foo(x) = puts x', error2)
  #   assert_syntax_error('private def obj.foo = puts "Hello"', error)
  #   assert_syntax_error('private def obj.foo() = puts "Hello"', error)
  #   assert_syntax_error('private def obj.foo(x) = puts x', error2)
  # end
end
RUBY
