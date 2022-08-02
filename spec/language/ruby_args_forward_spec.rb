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

  obj1 = Object.new
  def obj1.bar(*args, **kws, &block)
    if block
      block.call(args, kws)
    else
      [args, kws]
    end
  end
  obj4 = obj1.clone
  obj5 = obj1.clone
  obj1.instance_eval('def foo(...) bar(...) end', __FILE__, __LINE__)
  
  klass = Class.new {
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
  obj3.instance_eval('def foo(...) bar(...) end', __FILE__, __LINE__)

  ruby2_keywords =
    begin
      Object.new.tap { |obj| def obj.foo(a, k:); [a, k]; end; def obj.bar(*args); foo(*args); end }.bar(1, k: 2)
      true
    rescue ArgumentError
      false
    end

  [obj1, obj2, obj3].each.with_index do |obj, i|
    it "obj#{i + 1}" do
      assert_warning('') {
        assert_equal([[1, 2, 3], {k1: 4, k2: 5}], obj.foo(1, 2, 3, k1: 4, k2: 5) {|*x| x})
      }
      assert_warning('') {
        assert_equal([[1, 2, 3], {k1: 4, k2: 5}], obj.foo(1, 2, 3, k1: 4, k2: 5))
      }
      array = (obj == obj3) || ruby2_keywords ? [] : [{}]

      assert_warning('') {
        assert_equal([array, {}], obj.foo({}) {|*x| x})
      }
      assert_warning('') {
        assert_equal([array, {}], obj.foo({}))
      }
      assert_equal(-1, obj.method(:foo).arity)
      parameters = obj.method(:foo).parameters

      if ruby2_keywords
        assert_equal(:rest, parameters.dig(0, 0))
        assert_equal(:block, parameters.dig(1, 0))
      else
        assert_equal(:rest, parameters.dig(0, 0))
        assert_equal(:keyrest, parameters.dig(1, 0))
        assert_equal(:block, parameters.dig(2, 0))
      end
    end
  end

  it "with leading arguments" do
    obj = Object.new

    def obj.bar(*args, **kws, &block)
      if block
        block.call(args, kws)
      else
        [args, kws]
      end
    end

    obj.instance_eval('def foo(_a, ...) bar(...) end', __FILE__, __LINE__)

    assert_equal [[], {}], obj.foo(1)
    assert_equal [[2], {}], obj.foo(1, 2)
    assert_equal [[2, 3], {}], obj.foo(1, 2, 3)
    assert_equal [[], {a: 1}], obj.foo(1, a: 1)
    assert_equal [[2], {a: 1}], obj.foo(1, 2, a: 1)
    assert_equal [[2, 3], {a: 1}], obj.foo(1, 2, 3, a: 1)
    assert_equal [[2, 3], {a: 1}], obj.foo(1, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(...) bar(1, ...) end', __FILE__, __LINE__)

    assert_equal [[1], {}], obj.foo
    assert_equal [[1, 1], {}], obj.foo(1)
    assert_equal [[1, 1, 2], {}], obj.foo(1, 2)
    assert_equal [[1, 1, 2, 3], {}], obj.foo(1, 2, 3)
    assert_equal [[1], {a: 1}], obj.foo(a: 1)
    assert_equal [[1, 1], {a: 1}], obj.foo(1, a: 1)
    assert_equal [[1, 1, 2], {a: 1}], obj.foo(1, 2, a: 1)
    assert_equal [[1, 1, 2, 3], {a: 1}], obj.foo(1, 2, 3, a: 1)
    assert_equal [[1, 1, 2, 3], {a: 1}], obj.foo(1, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(a, ...) bar(a, ...) end', __FILE__, __LINE__)

    assert_equal [[4], {}], obj.foo(4)
    assert_equal [[4, 2], {}], obj.foo(4, 2)
    assert_equal [[4, 2, 3], {}], obj.foo(4, 2, 3)
    assert_equal [[4], {a: 1}], obj.foo(4, a: 1)
    assert_equal [[4, 2], {a: 1}], obj.foo(4, 2, a: 1)
    assert_equal [[4, 2, 3], {a: 1}], obj.foo(4, 2, 3, a: 1)
    assert_equal [[4, 2, 3], {a: 1}], obj.foo(4, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(_a, ...) bar(1, ...) end', __FILE__, __LINE__)

    assert_equal [[1], {}], obj.foo(4)
    assert_equal [[1, 2], {}], obj.foo(4, 2)
    assert_equal [[1, 2, 3], {}], obj.foo(4, 2, 3)
    assert_equal [[1], {a: 1}], obj.foo(4, a: 1)
    assert_equal [[1, 2], {a: 1}], obj.foo(4, 2, a: 1)
    assert_equal [[1, 2, 3], {a: 1}], obj.foo(4, 2, 3, a: 1)
    assert_equal [[1, 2, 3], {a: 1}], obj.foo(4, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(_a, _b, ...) bar(...) end', __FILE__, __LINE__)

    assert_equal [[], {}], obj.foo(4, 5)
    assert_equal [[2], {}], obj.foo(4, 5, 2)
    assert_equal [[2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(_a, _b, ...) bar(1, ...) end', __FILE__, __LINE__)

    assert_equal [[1], {}], obj.foo(4, 5)
    assert_equal [[1, 2], {}], obj.foo(4, 5, 2)
    assert_equal [[1, 2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[1], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[1, 2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[1, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[1, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(_a, ...) bar(1, 2, ...) end', __FILE__, __LINE__)

    assert_equal [[1, 2], {}], obj.foo(5)
    assert_equal [[1, 2, 5], {}], obj.foo(4, 5)
    assert_equal [[1, 2, 5, 2], {}], obj.foo(4, 5, 2)
    assert_equal [[1, 2, 5, 2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[1, 2, 5], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[1, 2, 5, 2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[1, 2, 5, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[1, 2, 5, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(a, b, ...) bar(b, a, ...) end', __FILE__, __LINE__)

    assert_equal [[5, 4], {}], obj.foo(4, 5)
    assert_equal [[5, 4, 2], {}], obj.foo(4, 5, 2)
    assert_equal [[5, 4, 2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[5, 4], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[5, 4, 2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[5, 4, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[5, 4, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(a, _b, ...) bar(a, ...) end', __FILE__, __LINE__)

    assert_equal [[4], {}], obj.foo(4, 5)
    assert_equal [[4, 2], {}], obj.foo(4, 5, 2)
    assert_equal [[4, 2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[4], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[4, 2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[4, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[4, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}

    obj.singleton_class.send(:remove_method, :foo)
    obj.instance_eval('def foo(a, ...) bar(a, 1, ...) end', __FILE__, __LINE__)

    assert_equal [[4, 1], {}], obj.foo(4)
    assert_equal [[4, 1, 5], {}], obj.foo(4, 5)
    assert_equal [[4, 1, 5, 2], {}], obj.foo(4, 5, 2)
    assert_equal [[4, 1, 5, 2, 3], {}], obj.foo(4, 5, 2, 3)
    assert_equal [[4, 1, 5], {a: 1}], obj.foo(4, 5, a: 1)
    assert_equal [[4, 1, 5, 2], {a: 1}], obj.foo(4, 5, 2, a: 1)
    assert_equal [[4, 1, 5, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1)
    assert_equal [[4, 1, 5, 2, 3], {a: 1}], obj.foo(4, 5, 2, 3, a: 1){|args, kws| [args, kws]}
  end
end
