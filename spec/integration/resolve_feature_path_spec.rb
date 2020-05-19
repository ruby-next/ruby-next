# frozen_string_literal: true

require_relative "../support/command_testing"

describe "$LOAD_PATH.resolve_feature_path" do
  it "catches unresolvable features" do
    run_ruby(
      "-ruby-next #{File.join(__dir__, "fixtures", "unresolvable_feature.rb")}"
    ) do |_status, output, _err|
      output.should include("OK")
    end
  end
end
