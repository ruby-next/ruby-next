# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "language features (via -ruby-next)" do
  it "nested array pattern matching" do
    run(
      "ruby -I#{File.join(__dir__, "../../lib")} -ruby-next -r #{File.join(__dir__, "fixtures", "nested_array.rb")} " \
      "-e 'p main([1, [2]]); p main([2, [2, 3]]); p main([1, [2, 3]])'"
    ) do |_status, output, _err|
      output.should include("2\n")
      output.should include("\"2 3\"\n")
      output.should include("\"2 [3]\"\n")
    end
  end
end
