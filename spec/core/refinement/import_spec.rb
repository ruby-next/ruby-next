# source: https://github.com/ruby/ruby/blob/524a808d23f1ed3eca946236e98e049b55458e71/test/ruby/test_refinement.rb#L2604-L2669

# Ruby 2.3- doesn't support top-level return and we neither
# In AST mode, we cannot correctly get the source location of imported methods,
# when they're transpiled.
# TruffleRuby and Ruby <2.7 do not support `using` within imported methods.
# Ruby 3.2+ does not have Refinement#include
if !defined?(TruffleRuby) && (RubyNext.current_ruby_version >= "2.7.0" && RubyNext.current_ruby_version < "3.2.0") && !RubyNext::Language.ast?

require_relative '../../spec_helper'
require_relative './fixtures/import'

ruby_version_is "3.1" do
  describe "Refinement#import_methods" do
    it "activates imported methods" do
      RefinementSpecs::Import::UsingC.call_bar.should == "refined:bar"
      RefinementSpecs::Import::UsingD.call_bar.should == "original:bar"
    end

    # it "supports attr accessors, define_method, aliases" do
    #   RefinementSpecs::Import::UsingC.call_baz.should == 42
    #   RefinementSpecs::Import::UsingD.call_baz.should == 42

    #   RefinementSpecs::Import::UsingC.call_fuu.should == 2021
    #   RefinementSpecs::Import::UsingD.call_fuu.should == 2021
    # end

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
