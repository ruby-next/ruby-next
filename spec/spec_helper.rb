# frozen_string_literal: true

# suppress "warning: <feature> is experimental, and the behavior may change in future versions of Ruby!"
$VERBOSE = nil

# override ruby_version_is method to always run tests
def ruby_version_is(*)
  yield
end

# Backports for older mspec
unless defined?(MSpecEnv)
  def suppress_warning
    yield
  end

  unless defined?(SkippedSpecError)
    def skip(_ = nil)
      1.should == 1
    end
  end
end

if !defined?(MSpecEnv) || !RubyNext::Utils.refine_modules?
  require_relative "test_unit_to_mspec"
end

root = File.dirname(__FILE__)
dir = "fixtures/code"
CODE_LOADING_DIR = File.realpath(dir, root)
