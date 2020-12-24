require_relative '../spec_helper'
require_relative 'fixtures/kwarg'

using RubyNext::Language::Eval

ruby_version_is "3.1" do
  describe "foo(x:)" do
    it "accepts short notation 'kwarg' in method call" do
      obj = KwargSpecs.new
      a, b, c = 1, 2, 3
      arr, h = eval('obj.call a:', binding)
      h.should == {a: 1}
      arr.should == []

      arr, h = eval('obj.call(a:, b:, c:)', binding)
      h.should == {a: 1, b: 2, c: 3}
      arr.should == []

      arr, h = eval('obj.call(a:, b: 10, c:)', binding)
      h.should == {a: 1, b: 10, c: 3}
      arr.should == []
    end

    it "handles identifiers" do
      obj = KwargSpecs.new

      obj.singleton_class.class_eval(<<-RUBY)
        def bar
          "baz"
        end

        def foo(val)
          call bar:, val:
        end
      RUBY

      obj.foo(1).should == [[], {bar: "baz", val: 1}]
    end
  end
end
