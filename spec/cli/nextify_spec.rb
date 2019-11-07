# frozen_string_literal: true

require_relative "spec_helper"
require "fileutils"

using CliTesting

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "dummy", ".rbnxt"))
  end

  it "generates .rbnxt/2.5 folder with the transpiled files" do
    run_cli "ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      err.should be_empty
      File.exist?(File.join(__dir__, "dummy", ".rbnxt", "2.5", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnxt", "2.5", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnxt", "2.5", "namespaced", "version.rb")).should equal false
    end
  end
end
