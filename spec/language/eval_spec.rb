# frozen_string_literal: true

require_relative '../spec_helper'
using RubyNext::Language::Eval

describe "transforming eval contents" do
  it "Kernel.eval" do
    eval(%q{
      case 2022
      when(2030..)
        :mysterious_future
      when(2020..)
        :twenties
      when(2010...)
        :nowish
      else
        :ancient_past
      end
    }).should == :twenties
  end

  it "Kernel.eval without binding" do
    next skip unless RubyNext::Language::Rewriters::PatternMatching.unsupported_syntax?
    # Here we rely on the fact that Hash#deconstruct_keys is not defined
    next skip if {}.respond_to?(:deconstruct_keys)

    eval(%q{
      case {status: :ok}
      in {status:}
        status
      else
        :unknown
      end
    }, nil).should  == :unknown
  end

  it "Kernel.eval with binding" do
    klass = Class.new
    eval(%q{
      case {status: :ok}
      in {status:}
        status
      else
        :unknown
      end
      },
      klass.send(:binding)
    ).should == :ok
  end

  it "Module.module_eval" do
    m = Module.new
    m.module_eval(%q{
      def self.foo(...)
        bar(...)
      end

      def self.bar(*args, a:)
        [args] + [a]
      end
    })

    m.foo(1, a: 2).should == [[1], 2]
  end

  it "Module.module_eval with binding locals" do
    m = Module.new do
      def foo
        "bar"
      end

      # Based on irb/extend-command.rb
      def self.def_aliases(name, *aliases)
        module_eval %q{
          for ali in aliases
            alias_method ali, name
          end
        }
      end
    end

    # We cannot access the locals from the original method
    # (in theory it could be possible with something like https://github.com/banister/debug_inspector or
    # binding_of_caller)
    -> {
      m.def_aliases "foo", "f", "fo"
    }.should raise_error(NameError)
  end

  it "Object.instance_eval" do
    obj = Object.new
    def obj.bar(x, y)
      x + y
    end

    obj.instance_eval("def foo(...) bar(...) end", __FILE__, __LINE__)

    obj.foo(1, 3).should == 4
  end
end
