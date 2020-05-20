# frozen_string_literal: true

# Convert test-unit assertions into mspec should matchers
module TestUnitToMspec
  module MSpecEnvExt
    def assert_equal(a, b)
      a.should == b
    end

    def assert_match(matcher, a)
      matcher = Regexp.new Regexp.escape matcher if String === matcher
      a.should =~ matcher
    end

    def assert_block(&block)
      val = !!block.call
      val.should == true
    end

    def assert_raise(error, &block)
      block.should raise_error(error)
    end

    def assert_nothing_raised(&block)
      block.should_not raise_error
    end

    def assert_syntax_error(str, *)
      -> { RubyNext::Language.transform(str) }.should raise_error(SyntaxError)
    end

    def assert_valid_syntax(str)
      -> { RubyNext::Language.transform(str) }.should_not raise_error
    end

    # Let's skip for now
    def assert_warning(*)
      yield
    end

    def assert_instance_of(klass, obj)
      (klass === obj).should == true
    end
  end

  if defined?(MSpecEnv) && RubyNext::Utils.refine_modules?
    refine MSpecEnv do
      include MSpecEnvExt
    end
  else
    Object.send(:include, TestUnitToMspec::MSpecEnvExt)
  end

  module KernelExt
    def eval(source, bind = nil, *other)
      source.gsub!(/def test_([\w_]+)/, 'it "\1" do')
      source.gsub!(/class Test(\w+).+$/, 'describe "\1" do')
      new_source = ::RubyNext::Language::Runtime.transform(
        source,
        using: bind&.receiver == TOPLEVEL_BINDING.receiver || bind&.receiver&.is_a?(Module)
      )
      RubyNext.debug_source(new_source, "(#{caller_locations(1, 1).first})")
      super new_source, bind, *other
    end
  end

  if RubyNext::Utils.refine_modules?
    refine Kernel do
      include TestUnitToMspec::KernelExt
    end
  else
    module ::Kernel
      alias_method :eval_without_transpile, :eval

      def eval(source, bind = nil, *other)
        source.gsub!(/def test_([\w_]+)/, 'it "\1" do')
        source.gsub!(/class Test(\w+).+$/, 'describe "\1" do')
        new_source = ::RubyNext::Language::Runtime.transform(
          source,
          using: bind&.receiver == TOPLEVEL_BINDING.receiver || bind&.receiver&.is_a?(Module)
        )
        RubyNext.debug_source(new_source, "(#{caller_locations(1, 1).first})")
        eval_without_transpile new_source, bind, *other
      end
    end
  end
end
