require_relative '../test_unit_to_mspec'

using TestUnitToMspec

eval <<~'RUBY', binding, __FILE__, __LINE__
using TestUnitToMspec

class TestSyntaxAnonymousArgsForwarding < Test::Unit::TestCase
  def test_anonymous_rest_forwarding
    assert_syntax_error("def b; c(*); end", /no anonymous rest parameter/)
    assert_syntax_error("def b; c(1, *); end", /no anonymous rest parameter/)

    obj = Class.new do
      def b(*); c(*) end
      def c(*a); a end
      def d(*); b(*, *) end
    end.new

    assert_equal([1, 2], obj.b(1, 2))
    assert_equal([1, 2, 1, 2], obj.d(1, 2))
  end

  def test_anonymous_keyword_rest_forwarding
    assert_syntax_error("def b; c(**); end", /no anonymous keyword rest parameter/)
    assert_syntax_error("def b; c(k: 1, **); end", /no anonymous keyword rest parameter/)

    obj = Class.new do
      def b(**); c(**) end
      def c(**kw); kw end
      def d(**); b(k: 1, **) end
      def e(**); b(**, k: 1) end
      def f(a: nil, **); b(**) end
    end.new

    assert_equal({a: 1, k: 3}, obj.b(a: 1, k: 3))
    assert_equal({a: 1, k: 3}, obj.d(a: 1, k: 3))
    assert_equal({a: 1, k: 1}, obj.e(a: 1, k: 3))
    assert_equal({k: 3}, obj.f(a: 1, k: 3))
  end
end
RUBY
