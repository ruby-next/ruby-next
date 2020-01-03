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

    # We do not check syntax, so make it no-op
    def assert_syntax_error(*)
      true.should == true
    end

    alias assert_valid_syntax assert_syntax_error

    # Let's skip for now
    def assert_warning(*)
      yield
    end
  end

  refine Kernel do
    def eval(contents, *other)
      contents.gsub!(/def test_([\w_]+)/, "it '\1' do")
      contents.gsub!(/class Test(\w+).+$/, "describe '\1' do")
      super
    end
  end
end
