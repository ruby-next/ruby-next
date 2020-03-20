# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "setup load path" do
  it "loads correct file versions" do
    skip if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7")
    run_ruby(
      "-I#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("failed;ok")
    end
  end

  it "ignores transpiled files if runtime mode is enabled for lib" do
    run_ruby(
      "-I#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen_runtime " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("ok;ok")
    end
  end
end
