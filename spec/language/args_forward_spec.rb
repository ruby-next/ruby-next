require_relative '../spec_helper'

using RubyNext::Language::ClassEval

ruby_version_is "2.7" do
  describe "args forwarding def(...)" do
    class F
      def target(*args, **kwargs)
        [args, kwargs]
      end

      def target_block(*args, **kwargs)
        yield [kwargs, args]
      end
    end

    it "delegates rest and kwargs" do
      a = Class.new(F)
      a.class_eval(<<-RUBY)
        def delegate(...)
          target(...)
        end
      RUBY

      a.new.delegate(1, b: 2).should == [[1], {b: 2}]
    end

    it "delegates block" do
      a = Class.new(F)
      a.class_eval(<<-RUBY)
        def delegate_block(...)
          target_block(...)
        end
      RUBY

      a.new.delegate_block(1, b: 2) { |x| x }.should == [{b: 2}, [1]]
    end
  end
end
