# frozen_string_literal: true

require_relative "../spec_helper"

using RubyNext::Language::Eval

ruby_version_is "2.5" do
  describe "rescue within do...end block" do
    it "catches an exception in lambda" do
      error = eval("lambda do
                      raise 'error'
                    rescue
                      $!
                    end.call", binding)

      error.class.should == RuntimeError
    end

    it "raises SyntaxError with arrow block" do
      lambda do
        eval("-> {
               raise 'err'
               rescue
                  $!
               end
             }.call", binding)
      end.should raise_error SyntaxError
    end

    it "rescues when passing block to method" do
      lambda do
        eval("def a; yield end
              a do
                raise 'err'
              rescue
                $!
              end",
          binding)
      end.should_not raise_error SyntaxError
    end

    it "raises SyntaxError with basic loop" do
      lambda do
        eval("while do
                raise 'err'
              rescue
                $!
              end", binding)
      end.should raise_error SyntaxError
    end

    it "supports an old syntax" do
      lambda do
        eval("lambda do
                begin
                  raise 'err'
                rescue
                  $! # => #<RuntimeError: err>
                end
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    it "rescues inside Procs" do
      lambda do
        eval("Proc.new do
                raise 'err'
              rescue
                $!
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    it "rescues with additional ensure keyword" do
      lambda do
        eval("lambda do
                raise 'err'
              rescue
                $!
              ensure
                :ensure
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    it "rescues when error was throwed" do
      lambda do
        eval("lambda do
                throw 'err'
              rescue
                $!
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    it "accepts block without error" do
      lambda do
        eval("lambda do
                :hello
              ensure
                :test
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    it "rescues when exception occurs in calling method" do
      lambda do
        eval("def a; raise 'err' end
              lambda do
                a
              rescue
                $!
              end.call", binding)
      end.should_not raise_error SyntaxError
    end

    context "iterators" do
      it "raises SyntaxError in block-like loop" do
        lambda do
          eval("for i in 1..5 do
                  raise 'err'
                rescue
                  $!
                end", binding)
        end.should raise_error SyntaxError
      end

      it "catches exception in iterators with block" do
        lambda do
          eval("[1, 2].each do |i|
                  raise 'error'
                rescue
                  $!
                end", binding)
        end.should_not raise_error SyntaxError
      end
    end
  end
end
