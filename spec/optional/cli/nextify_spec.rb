# frozen_string_literal: true

require_relative "../../support/command_testing"
require "fileutils"

using CommandTesting

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, ".rbnext"))
  end

  it "--enable-method-reference" do
    run(
      "bin/ruby-next nextify #{File.join(__dir__, "..", "integration", "fixtures", "method_reference.rb")} --enable-method-reference",
      "-o #{File.join(__dir__, ".rbnext", "method_reference_old.rb")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, ".rbnext", "method_reference_old.rb")).should equal true
      File.read(File.join(__dir__, ".rbnext", "method_reference_old.rb")).should include("JSON.method(:parse)")
    end
  end
end
