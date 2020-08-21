require_relative '../spec_helper'

using RubyNext::Language::Eval

ruby_version_is "2.8" do
  describe "1 => x" do
    class RightHandSpec
    end

    it "with expression" do
      a = 2
      eval <<-RUBY
        if a > 1
          1
        else
          0
        end => @x
      RUBY

      @x.should == 1
    end

    it "with right-hand method call" do
      x = eval <<-RUBY
        (5 + 3 => x).
          then(&:to_s)
      RUBY

      x.should == "8"
    end
  end
end
