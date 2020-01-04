# frozen_string_literal: true

require_relative "../../support/command_testing"

using CommandTesting

describe "optional language features (via -ruby-next)" do
  it "method reference" do
    cmd = <<~CMD
      ruby -I#{File.join(__dir__, "../../../lib")} -ruby-next -r #{File.join(__dir__, "fixtures", "method_reference.rb")} \
      -e "p main({}.to_json); p main({status: :ok}.to_json)"
    CMD

    run(cmd,
      env: {"RUBY_NEXT_ENABLE_METHOD_REFERENCE" => "1"}) do |_status, output, _err|
      output.should include("\"status: \"\n")
      output.should include("\"status: ok\"\n")
    end
  end
end
