# frozen_string_literal: true

require_relative "../support/command_testing"

describe "rewrite mode" do
  it "preserves lines" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "fixtures", "rewrite.rb")} " \
      "--transpile-mode=rewrite -o stdout --edge --proposed --single-version"
    ) do |_status, output, err|
      output.lines.size.should equal(
        File.read(File.join(__dir__, "fixtures", "rewrite.rb")).lines.size
      )
    end
  end
end
