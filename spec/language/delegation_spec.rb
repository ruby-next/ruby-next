# source: https://github.com/ruby/spec/blob/249a36c2e9fcddbb208a0d618d05f6bd9a64fd17/language/delegation_spec.rb#L1

require_relative '../spec_helper'
require_relative 'fixtures/delegation'

using RubyNext::Language::Eval

ruby_version_is "2.7" do
  describe "delegation with def(...)" do
    it "delegates rest and kwargs" do
      a = Class.new(DelegationSpecs::Target)
      a.class_eval(<<-RUBY)
        def delegate(...)
          target(...)
        end
      RUBY

      a.new.delegate(1, b: 2).should == [[1], {b: 2}]
    end

    it "delegates block" do
      a = Class.new(DelegationSpecs::Target)
      a.class_eval(<<-RUBY)
        def delegate_block(...)
          target_block(...)
        end
      RUBY

      a.new.delegate_block(1, b: 2) { |x| x }.should == [{b: 2}, [1]]
    end

    if RUBY_VERSION >= "2.6.0"
      it "parses as open endless Range when brackets are omitted" do
        a = Class.new(DelegationSpecs::Target)
        suppress_warning do
          a.class_eval(<<-RUBY)
            def delegate(...)
              target ...
            end
          RUBY
        end

        a.new.delegate(1, b: 2).should == Range.new([[], {}], nil, true)
      end
    end
  end

  describe "anonymous block delegation" do
    ruby_version_is "3.1" do
      it "delegates block" do
        result = nil

        Class.new do
          result = class_eval(<<~RUBY)
            def self.b(&) = c(&)
            def self.c(&) = yield(1)

            a = nil

            instance_eval do
              b { |c| a = c }
            end

            a
          RUBY
        end

        result.should == 1
      end

      it "delegates block to super" do
        k = Class.new do
          def b(v, &block)
            block.call(v)
          end

          def c
            yield 1
          end
        end

        sk = Class.new(k) do
          class_eval <<~RUBY
            def b(v, &)
              super
            end

            def c(&)
              super(&)
            end
          RUBY
        end

        a = sk.new

        a.b(1) { |v| v + 2 }.should == 3
        a.c(&:itself).should == 1
      end
    end
  end
end
