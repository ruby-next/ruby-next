# frozen_string_literal: true

require_relative "../support/command_testing"

describe "refinements ignore monkey-patching" do
  it "works" do
    run_ruby(
      File.join(__dir__, "fixtures", "monkey.rb").to_s
    ) do |_status, output, _err|
      if RUBY_VERSION >= "3.4"
        output.should include("RESULT: {a: 1}\n")
      else
        output.should include("RESULT: {:a=>1}\n")
      end
    end
  end
end
