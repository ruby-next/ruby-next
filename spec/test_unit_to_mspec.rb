# frozen_string_literal: true

# Convert test-unit assertions into mspec should matchers
module TestUnitToMspec
  module CheckSyntax
    module_function

    def call(source)
      new_source = RubyNext::Language.transform(source, rewriters: RubyNext::Language.current_rewriters)

      catch(:valid) do
        eval("BEGIN{throw :valid}\nObject.new.instance_eval { #{new_source} }") # rubocop:disable all
      end
    end
  end

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

    def assert_raise_with_message(error, msg, &block)
      block.should raise_error(error)
    end

    def assert_nothing_raised(&block)
      block.should_not raise_error
    end

    def assert_syntax_error(str, *)
      -> { CheckSyntax.call(str) }.should raise_error(SyntaxError)
    end

    def assert_valid_syntax(str)
      -> { CheckSyntax.call(str) }.should_not raise_error
    end

    # Let's skip for now
    def assert_warning(*)
      yield
    end

    def assert_instance_of(klass, obj)
      (klass === obj).should == true
    end

    def assert_separately(_args, source)
      obj = Object.new
      obj.singleton_class.include MSpecEnvExt
      new_source = ::RubyNext::Language::Runtime.transform(source, using: false)
      obj.instance_eval(new_source)
    end
  end

  if defined?(MSpecEnv) && RubyNext::Utils.refine_modules?
    refine MSpecEnv do
      if RUBY_VERSION >= "3.1.0"
        import_methods MSpecEnvExt
      else
        include MSpecEnvExt
      end
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
      super(new_source, bind, *other)
    end
  end

  if ENV["DISABLE_REQUIRE_HOOKS"] != "true" && defined?(RubyNext::Language)
    if RubyNext::Utils.refine_modules?
      refine Kernel do
        # TrufflyRuby doesn't support super in imported methods:
        # https://github.com/oracle/truffleruby/issues/2971
        if RUBY_VERSION >= "3.1.0"
          import_methods TestUnitToMspec::KernelExt
        else
          include TestUnitToMspec::KernelExt
        end
      end
    else
      module ::Kernel
        alias_method :eval_without_transpile, :eval

        def eval(src, bind = nil, *other)
          source = src.gsub(/def test_([\w_]+)/, 'it "\1" do')
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
end
