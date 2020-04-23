# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "edge/proposed features via require" do
  it "proposed features" do
    cmd = <<~CMD
      ruby -rbundler/setup -I#{File.join(__dir__, "../../../lib")} -r #{File.join(__dir__, "fixtures", "proposed.rb")} \
      -e "p main({}.to_json); p main({status: :ok}.to_json)"
    CMD

    # Set env var to 0 to make sure we do not shadow it
    run(cmd, env: {"RUBY_NEXT_PROPOSED" => "0"}) do |_status, output, _err|
      output.should include("\"status: \"\n")
      output.should include("\"status: ok\"\n")
    end
  end
end
