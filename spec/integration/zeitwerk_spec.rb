# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/command_testing"

describe "zeitwerk compatibility" do
  it "works" do
    # Zeitwerk requires Ruby 2.4+
    next skip unless RUBY_VERSION >= "2.4.0"

    run_ruby(
      File.join(__dir__, "fixtures", "zeitwerk", "test.rb").to_s
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end
end
