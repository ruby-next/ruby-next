# frozen_string_literal: true

require_relative "../support/command_testing"
require "fileutils"

using CommandTesting

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "fixtures", ".rbnext"))
  end

  it "generates valid ruby code" do
    run "bin/ruby-next nextify #{File.join(__dir__, "fixtures", "beach.rb")}"

    version_dir = RubyNext.next_version.segments[0..1].join(".")

    unless File.exist?(File.join(__dir__, "fixtures", ".rbnext", version_dir))
      version_dir = Dir.children(File.join(__dir__, "fixtures", ".rbnext")).first
    end

    run(
      "ruby -I#{File.join(__dir__, "../../lib")} -r ruby-next -r #{File.join(__dir__, "fixtures", ".rbnext", version_dir, "beach.rb")} " \
      "-e 'puts beach(:k, 300)'"
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end
end
