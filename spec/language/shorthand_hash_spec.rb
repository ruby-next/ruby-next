require_relative '../spec_helper'

using RubyNext::Language::Eval

ruby_version_is "3.1" do
  describe "{x:}" do
    it "accepts short notation 'key' for 'key: value' syntax" do
      a, b, c = 1, 2, 3
      h = eval('{a:}', binding)
      {a: 1}.should == h
      h = eval('{a:, b:, c:}', binding)
      {a: 1, b: 2, c: 3}.should == h
    end

    it "ignores hanging comma on short notation" do
      a, b, c = 1, 2, 3
      h = eval('{a:, b:, c:,}', binding)
      {a: 1, b: 2, c: 3}.should == h
    end

    it "accepts mixed 'key', 'key: value', 'key => value' and '\"key\"': value' syntax" do
      a, e = 1, 5
      h = eval('{a:, :b => 2, "c" => 3, :d => 4, e:}', binding)
      eval('{a: 1, :b => 2, "c" => 3, "d": 4, e: 5}', binding).should == h
    end

    it "handles identifiers" do
      a = Class.new
      a.class_eval(<<-RUBY)
        def bar
          "baz"
        end

        def foo(val)
          {bar:, val:}
        end
      RUBY

      a.new.foo(1).should == {bar: "baz", val: 1}
    end
  end
end
