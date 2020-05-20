# frozen_string_literal: true

require_relative "../support/command_testing"

describe "bootsnap compatibility" do
  it "works" do
    next skip if defined?(JRUBY_VERSION) || defined?(TruffleRuby)

    cache_path = File.join(__dir__, "fixtures", "bootsnap", "tmp")
    if File.directory?(cache_path)
      FileUtils.rm_rf(cache_path)
    end

    run_ruby(
      File.join(__dir__, "fixtures", "bootsnap", "test.rb").to_s
    ) do |_status, output, _err|
      output.should include("PERFORM: ruby_next#test\n")
      output.should include("UNKNOWN: perform\n")
    end
  end
end
