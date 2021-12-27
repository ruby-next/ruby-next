# source: https://github.com/ruby/ruby/blob/524a808d23f1ed3eca946236e98e049b55458e71/test/ruby/test_refinement.rb#L2604-L2669

# Ruby 2.3- doesn't support top-level return and we neither
unless RUBY_VERSION >= "3.1.0"

require_relative '../../spec_helper'

module RefinementSpecs
  module Import
    class A
      def foo
        "original"
      end
    end

    module B
      BAR = "bar"

      def bar(); "#{foo}:#{BAR}"; end
    end

    module C
      using RubyNext

      refine A do
        import_methods B

        def foo
          "refined"
        end
      end
    end

    module D
      refine A do
        include B

        def foo
          "refined"
        end
      end
    end

    module UsingC
      using C

      def self.call_bar
        A.new.bar
      end
    end

    module UsingD
      using D

      def self.call_bar
        A.new.bar
      end
    end
  end
end

ruby_version_is "3.1" do
  describe "Refinement#import_methods" do
    it "activates imported methods" do
      RefinementSpecs::Import::UsingC.call_bar.should == "refined:bar"
      RefinementSpecs::Import::UsingD.call_bar.should == "original:bar"
    end

    it "raises ArgumentError when trying to import C methods" do
      proc do
        Module.new do
          refine Integer do
            import_methods Enumerable
          end
        end
      end.should raise_error(ArgumentError)
    end
  end
end

end
