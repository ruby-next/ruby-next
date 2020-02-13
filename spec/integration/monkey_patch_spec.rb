# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "refinements ignore monkey-patching" do
  it "works" do
    run(
      "ruby -rbundler/setup -I#{File.join(__dir__, "../../lib")} "\
      "#{File.join(__dir__, "fixtures", "monkey.rb")}"
    ) do |_status, output, _err|
      output.should include("RESULT: {:a=>1}\n")
    end
  end
end
