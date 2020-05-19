# frozen_string_literal: true

require_relative "../support/command_testing"
require "fileutils"

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "fixtures", ".rbnext"))
  end

  it "generates valid ruby code" do
    run_ruby_next "nextify #{File.join(__dir__, "fixtures", "beach.rb")}"

    version_dir = RubyNext.next_version&.then { |v| v.segments[0..1].join(".") }

    if version_dir.nil? || !File.exist?(File.join(__dir__, "fixtures", ".rbnext", version_dir))
      version_dir = Dir.children(File.join(__dir__, "fixtures", ".rbnext")).sort.first # rubocop:disable Style/RedundantSort
    end

    run_ruby(
      "-r ruby-next -r #{File.join(__dir__, "fixtures", ".rbnext", version_dir, "beach.rb")} " \
      "-e 'puts beach(:k, 300)'"
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end
end
