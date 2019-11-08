# frozen_string_literal: true

require_relative "spec_helper"
require "fileutils"

using CliTesting

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "dummy", ".rbnext"))
  end

  it "generates .rbnxt/2.6 folder with the transpiled files required for 2.6" do
    run_cli "ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "endless_nameless.rb")).should equal false
    end
  end

  it "generates .rbnxt/2.5 folder with the transpiled files required for 2.5" do
    run_cli "ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "pattern_matching.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates two version for mixed files (both 2.6 and 2.7 features)" do
    run_cli "ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "endless_pattern.rb")).should equal true
    end
  end
end
