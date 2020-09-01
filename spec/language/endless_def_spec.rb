require_relative '../spec_helper'

using RubyNext::Language::ClassEval

ruby_version_is "3.0" do
  describe "def x() = y" do
    class EndlessDefSpec
    end

    it "without arguments" do
      a = Class.new(EndlessDefSpec)
      a.class_eval(<<-RUBY)
        def num() = 42
      RUBY

      a.new.num.should == 42
    end

    it "with arguments" do
      a = Class.new(EndlessDefSpec)
      a.class_eval(<<-RUBY)
        def add(a, b) = a + b
      RUBY

      a.new.add(1, 4).should == 5
    end

    it "with multiline body" do
      a = Class.new(EndlessDefSpec)
      a.class_eval(<<-RUBY)
        def fib(n) =
          if n > 2
            fib(n - 2) + fib(n - 1)
          else
            1
          end
      RUBY

      a.new.fib(6).should == 8
    end
  end
end
