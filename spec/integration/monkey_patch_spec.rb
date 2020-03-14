# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "refinements ignore monkey-patching" do
  it "works" do
    run_ruby(
      File.join(__dir__, "fixtures", "monkey.rb").to_s
    ) do |_status, output, _err|
      output.should include("RESULT: {:a=>1}\n")
    end
  end
end
