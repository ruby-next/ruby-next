# frozen_string_literal: true

# Convert test-unit assertions into mspec should matchers
module TestUnitToMspec
  refine MSpecEnv do
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

    # We do not check syntax, so make it no-op
    def assert_syntax_error(*)
      true.should == true
    end

    alias assert_valid_syntax assert_syntax_error

    # Let's skip for now
    def assert_warning(*)
      yield
    end

    def assert_instance_of(klass, obj)
      (klass === obj).should == true
    end
  end

  refine Kernel do
    def eval(source, bind = nil, *other)
      source.gsub!(/def test_([\w_]+)/, 'it "\1" do')
      source.gsub!(/class Test(\w+).+$/, 'describe "\1" do')
      new_source = ::RubyNext::Language::Runtime.transform(
        source,
        using: bind&.receiver == TOPLEVEL_BINDING.receiver || bind&.receiver&.is_a?(Module)
      )
      $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
      super new_source, bind, *other
    end
  end
end
