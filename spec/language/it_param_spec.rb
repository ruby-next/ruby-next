# source: https://github.com/ruby/spec/blob/249a36c2e9fcddbb208a0d618d05f6bd9a64fd17/language/numbered_parameters_spec.rb

require_relative '../spec_helper'

using RubyNext::Language::Eval

ruby_version_is "3.4" do
  describe "it parameter" do
    it "provides default parameters it in a block" do
      -> { it }.call("a").should == "a"
      proc { it }.call("a").should == "a"
      lambda { it }.call("a").should == "a"
      ["a"].map { it }.should == ["a"]
    end

    it "assigns nil to not passed parameter" do
      proc { [it] }.call.should == [nil]
    end

    it "do not overwrite already defined local variable" do
      # FIXME: We do not support shadowing, 'cause it doesn't play well with Prism
      # JRuby doesn't support it yet, but claims RUBY_VERSION ~> 3.4
      next skip unless (RUBY_VERSION >= "3.4.0" && !defined?(JRUBY_VERSION))
      it = 42
      proc { it }.call("a").should == 42
    end

    it "can be overwritten with local variable" do
      proc { it = 42; it }.call("a").should == 42
    end

    it "raises SyntaxError when block parameters are specified explicitly" do
      next skip unless (RUBY_VERSION >= "3.4.0" && !defined?(JRUBY_VERSION))
      -> { eval("-> () { it }")         }.should raise_error(SyntaxError, /ordinary parameter is defined/)
      -> { eval("-> (x) { it }")        }.should raise_error(SyntaxError, /ordinary parameter is defined/)

      -> { eval("proc { || it }")       }.should raise_error(SyntaxError, /ordinary parameter is defined/)
      -> { eval("proc { |x| it }")      }.should raise_error(SyntaxError, /ordinary parameter is defined/)

      -> { eval("lambda { || it }")     }.should raise_error(SyntaxError, /ordinary parameter is defined/)
      -> { eval("lambda { |x| it }")    }.should raise_error(SyntaxError, /ordinary parameter is defined/)

      -> { eval("['a'].map { || it }")  }.should raise_error(SyntaxError, /ordinary parameter is defined/)
      -> { eval("['a'].map { |x| it }") }.should raise_error(SyntaxError, /ordinary parameter is defined/)
    end

    it "affects block arity" do
      -> { it }.arity.should == 1
      proc   { it }.arity.should == 1
      lambda { it }.arity.should == 1
    end

    it "does not work in methods" do
      obj = Object.new
      def obj.foo; it end

      -> { obj.foo("a") }.should raise_error(ArgumentError, /wrong number of arguments/)
    end
  end
end
