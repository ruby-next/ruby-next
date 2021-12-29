# source: https://github.com/ruby/ruby/blob/524a808d23f1ed3eca946236e98e049b55458e71/test/ruby/test_refinement.rb#L2604-L2669

# Ruby 2.3- doesn't support top-level return and we neither
# In AST mode, we cannot correctly get the source location of imported methods,
# when they're transpiled
unless RUBY_VERSION >= "3.1.0" || RubyNext::Language.ast?

require_relative '../../spec_helper'

module RefinementSpecs
  module Import
    class A
      def initialize
        @baz = 42
        @fuu = 2021
      end

      def foo
        "original"
      end
    end

    module B
      BAR = "bar"

      def bar(); "#{foo}:#{BAR}"; end

      unless defined?(JRUBY_VERSION)
        attr_reader :fuu
      end

      define_method(:baz) { @baz }
    end

    module C
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

      def self.call_baz
        A.new.baz
      end

      def self.call_fuu
        A.new.fuu
      end
    end

    module UsingD
      using D

      def self.call_bar
        A.new.bar
      end

      def self.call_baz
        A.new.baz
      end

      def self.call_fuu
        A.new.fuu
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

    it "supports attr accessors, define_method, aliases" do
      RefinementSpecs::Import::UsingC.call_baz.should == 42
      RefinementSpecs::Import::UsingD.call_baz.should == 42

      unless defined?(JRUBY_VERSION)
        RefinementSpecs::Import::UsingC.call_fuu.should == 2021
        RefinementSpecs::Import::UsingD.call_fuu.should == 2021
      end
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
