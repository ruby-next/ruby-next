# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "runtime preserves lexical scope" do
  it "works" do
    run_ruby(
      File.join(__dir__, "fixtures", "lexical_scope", "run.rb").to_s
    ) do |_status, output, _err|
      output.should include("Refined: 0")
      output.should include("Not refined: 1")
    end
  end
end
