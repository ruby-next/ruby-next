# frozen_string_literal: true

require_relative "../support/command_testing"
require "fileutils"

describe "transpiled code should work on recent versions" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "fixtures", ".rbnext"))
  end

  it "keyword arguments vs forwarding" do
    run_ruby_next "nextify #{File.join(__dir__, "fixtures", "delegation.rb")} --min-version=2.5 --single-version"

    run_ruby(
      "-r ruby-next -r #{File.join(__dir__, "fixtures", ".rbnext", "delegation.rb")} " \
      "-e 'puts Repeater.wrapped(repeatOnce(word: \"x\"), repeats(2, word: \"y\"), 2, word: Repeater.new.prefixed(\"z\", 2, word: \"a\"))'"
    ) do |_status, output, _err|
      output.should include("xzaazaayy")
    end
  end
end
