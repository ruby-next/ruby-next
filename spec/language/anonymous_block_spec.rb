require_relative '../spec_helper'
require_relative 'fixtures/kwarg'

using RubyNext::Language::Eval

describe "Anonymous block forwarding" do
  ruby_version_is "3.1" do
    it "forwards blocks to other functions that formally declare anonymous blocks" do
      eval <<-EOF
          def b(&); c(&) end
          def c(&); yield :non_null end
      EOF

      b { |c| c }.should == :non_null
    end

    it "requires the anonymous block parameter to be declared if directly passing a block" do
      -> { eval "def a; b(&); end; def b; end" }.should raise_error(SyntaxError)
    end

    it "works when it's the only declared parameter" do
      eval <<-EOF
          def inner; yield end
          def block_only(&); inner(&) end
      EOF

      block_only { 1 }.should == 1
    end

    it "works alongside positional parameters" do
      eval <<-EOF
          def inner; yield end
          def pos(arg1, &); inner(&) end
      EOF

      pos(:a) { 1 }.should == 1
    end

    it "works alongside positional arguments and splatted keyword arguments" do
      eval <<-EOF
          def inner; yield end
          def pos_kwrest(arg1, **kw, &); inner(&) end
      EOF

      pos_kwrest(:a, arg: 3) { 1 }.should == 1
    end

    it "works alongside positional arguments and disallowed keyword arguments" do
      # We do not support **nil
      next skip if RUBY_VERSION < "2.7.0"

      eval <<-EOF
          def inner; yield end
          def no_kw(arg1, **nil, &); inner(&) end
      EOF

      no_kw(:a) { 1 }.should == 1
    end
  end

  ruby_version_is "3.2" do
    it "works alongside explicit keyword arguments" do
      eval <<-EOF
          def inner; yield end
          def rest_kw(*a, kwarg: 1, &); inner(&) end
          def kw(kwarg: 1, &); inner(&) end
          def pos_kw_kwrest(arg1, kwarg: 1, **kw, &); inner(&) end
          def pos_rkw(arg1, kwarg1:, &); inner(&) end
          def all(arg1, arg2, *rest, post1, post2, kw1: 1, kw2: 2, okw1:, okw2:, &); inner(&) end
          def all_kwrest(arg1, arg2, *rest, post1, post2, kw1: 1, kw2: 2, okw1:, okw2:, **kw, &); inner(&) end
      EOF

      rest_kw { 1 }.should == 1
      kw { 1 }.should == 1
      pos_kw_kwrest(:a) { 1 }.should == 1
      pos_rkw(:a, kwarg1: 3) { 1 }.should == 1
      all(:a, :b, :c, :d, :e, okw1: 'x', okw2: 'y') { 1 }.should == 1
      all_kwrest(:a, :b, :c, :d, :e, okw1: 'x', okw2: 'y') { 1 }.should == 1
    end
  end
end
