# frozen_string_literal: true

require_relative "../support/command_testing"
require "fileutils"

using CommandTesting

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "dummy", ".rbnext"))
  end

  it "generates .rbnxt/2.6 folder with the transpiled files required for 2.6" do
    run "bin/ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "endless_nameless.rb")).should equal false
    end
  end

  it "generates .rbnxt/2.5 folder with the transpiled files required for 2.5" do
    run "bin/ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "pattern_matching.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates one version if --single-version is provided" do
    run(
      "bin/ruby-next nextify #{File.join(__dir__, "dummy")}",
      "--single-version"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates .rbnxt/custom folder with versions" do
    run(
      "bin/ruby-next nextify #{File.join(__dir__, "dummy")}",
      "--output=#{File.join(__dir__, "dummy", ".rbnext", "custom")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "custom", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "custom", "2.6", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates two version for mixed files (both 2.6 and 2.7 features)" do
    run "bin/ruby-next nextify #{File.join(__dir__, "dummy")}" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "endless_pattern.rb")).should equal true
    end
  end

  it "can generate a single file and store it into a specified path" do
    run(
      "bin/ruby-next nextify #{File.join(__dir__, "dummy", "transpile_me.rb")}",
      "-o #{File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should include("deconstruct_keys([:status])")
    end
  end

  it "can generate a single file with the specified min version and store it into a specified path" do
    run(
      "ruby-next nextify #{File.join(__dir__, "dummy", "endless_pattern.rb")}",
      "-o #{File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")} --min-version=2.6"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")).should include("(1..)")
    end
  end

  it "can generate multiple files from a single file and print logs" do
    run(
      "ruby-next nextify #{File.join(__dir__, "dummy", "endless_pattern.rb")}",
      "-V"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
    end
  end

  it "fails when syntax is unsupported and not enabled explicitly" do
    run(
      "bin/ruby-next nextify #{File.join(__dir__, "..", "optional", "integration", "fixtures", "method_reference.rb")}",
      "-o #{File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")}",
      should_fail: true
    ) do |status, output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")).should equal false
    end
  end
end
