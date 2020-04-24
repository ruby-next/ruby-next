# source: https://github.com/ruby/ruby/blob/b609bdeb5307e280137b4b2838af0fe4e4b46f1c/test/ruby/test_syntax.rb#L1474

require_relative '../test_unit_to_mspec'

using RubyNext::Language::InstanceEval
using TestUnitToMspec

describe "args forwarding def(...)" do
  it "syntax" do
    assert_valid_syntax('def foo(...) bar(...) end')
    assert_valid_syntax('def foo(...) end')
    assert_syntax_error('iter do |...| end', /unexpected/)
    assert_syntax_error('iter {|...|}', /unexpected/)
    assert_syntax_error('->... {}', /unexpected/)
    assert_syntax_error('->(...) {}', /unexpected/)
    assert_syntax_error('def foo(x, y, z) bar(...); end', /unexpected/)
    assert_syntax_error('def foo(x, y, z) super(...); end', /unexpected/)
    assert_syntax_error('def foo(...) yield(...); end', /unexpected/)
    assert_syntax_error('def foo(...) return(...); end', /unexpected/)
    assert_syntax_error('def foo(...) a = (...); end', /unexpected/)
    assert_syntax_error('def foo(...) [...]; end', /unexpected/)
    assert_syntax_error('def foo(...) foo[...]; end', /unexpected/)
    assert_syntax_error('def foo(...) foo[...] = x; end', /unexpected/)
    assert_syntax_error('def foo(...) foo(...) { }; end', /both block arg and actual block given/)
    assert_syntax_error('def foo(...) defined?(...); end', /unexpected/)
  end

  # FIXME: figure out how to deal with full kwargs separation
  # https://github.com/ruby/ruby/pull/2794
  next if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7")

  obj1 = Object.new
  def obj1.bar(*args, **kws, &block)
    if block
      block.call(args, kws)
    else
      [args, kws]
    end
  end
  def obj1.name; "obj1"; end
  obj1.instance_eval('def foo(...) bar(...) end', __FILE__, __LINE__)

  klass = Class.new {
    def name; "obj2"; end
    def foo(*args, **kws, &block)
      if block
        block.call(args, kws)
      else
        [args, kws]
      end
    end
  }
  obj2 = klass.new
  obj2.instance_eval('def foo(...) super(...) end', __FILE__, __LINE__)

  obj3 = Object.new
  def obj3.bar(*args, &block)
    if kws = Hash.try_convert(args.last)
      args.pop
    else
      kws = {}
    end
    if block
      block.call(args, kws)
    else
      [args, kws]
    end
  end
  def obj3.name; "obj3"; end
  obj3.instance_eval('def foo(...) bar(...) end', __FILE__, __LINE__)

  [obj1, obj2, obj3].each do |obj|
    it obj.name do
      assert_warning('') {
        assert_equal([[1, 2, 3], {k1: 4, k2: 5}], obj.foo(1, 2, 3, k1: 4, k2: 5) {|*x| x})
      }
      assert_warning('') {
        assert_equal([[1, 2, 3], {k1: 4, k2: 5}], obj.foo(1, 2, 3, k1: 4, k2: 5))
      }
      warning = "warning: The last argument is used as the keyword parameter"
      assert_warning(/\A\z|:(?!#{__LINE__+1})\d+: #{warning}/o) {
        assert_equal([[], {}], obj.foo({}) {|*x| x})
      }
      assert_warning(/\A\z|:(?!#{__LINE__+1})\d+: #{warning}/o) {
        assert_equal([[], {}], obj.foo({}))
      }
      assert_equal(-1, obj.method(:foo).arity)

      parameters = obj.method(:foo).parameters
      assert_equal(:rest, parameters.dig(0, 0))
      assert_equal(:block, parameters.dig(1, 0))
    end
  end
end
