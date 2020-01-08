# source: https://github.com/ruby/ruby/blob/master/test/ruby/test_syntax.rb#L1477

require_relative '../test_unit_to_mspec'

using RubyNext::Language::InstanceEval
using TestUnitToMspec

describe "args forwarding def(...)" do
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

      # FIXME: As is as this patch is released: https://github.com/ruby/ruby/commit/b609bdeb5307e280137b4b2838af0fe4e4b46f1c
      next if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7")
      parameters = obj.method(:foo).parameters
      assert_equal(:rest, parameters.dig(0, 0))
      assert_equal(:block, parameters.dig(1, 0))
    end
  end

  class F
    def delegate(...)
      target(...)
    end

    def delegate_block(...)
      target_block(...)
    end

    def target(*args, **kwargs)
      [args, kwargs]
    end

    def target_block(*args, **kwargs)
      yield [kwargs, args]
    end
  end

  it "delegates rest and kwargs" do
    F.new.delegate(1, b: 2).should == [[1], {b: 2}]
  end

  it "delegates block" do
    F.new.delegate_block(1, b: 2) { |x| x }.should == [{b: 2}, [1]]
  end
end
