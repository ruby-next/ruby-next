# frozen_string_literal: true

require_relative "../support/command_testing"

describe "zeitwerk compatibility" do
  it "works" do
    # Zeitwerk doesn't support JRuby
    # https://github.com/fxn/zeitwerk/issues/6#issuecomment-457863863
    next skip if defined?(JRUBY_VERSION) || defined?(TruffleRuby)
    run_ruby(
      File.join(__dir__, "fixtures", "zeitwerk", "test.rb").to_s
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end
end
