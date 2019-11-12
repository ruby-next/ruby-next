# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "setup load path" do
  it "loads correct file versions" do
    run(
      "ruby -I#{File.join(__dir__, "../../lib")}:#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("failed;ok")
    end
  end
end
