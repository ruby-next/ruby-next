# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "ruby -ruby-next" do
  it "transform code in runtime" do
    run(
      "ruby -I#{File.join(__dir__, "../../lib")} -ruby-next -r #{File.join(__dir__, "fixtures", "beach.rb")} " \
      "-e 'puts beach(:k, 300)'"
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end
end
