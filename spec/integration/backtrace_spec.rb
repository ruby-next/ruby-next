# frozen_string_literal: true

require_relative "../support/command_testing"

describe "patch has source location meta" do
  it "works" do
    next skip if RUBY_VERSION >= "2.7"

    source_path = Pathname.new(File.join(__dir__, "../../lib/ruby-next/core/enumerator/produce.rb")).realpath
    source_line = File.open(source_path).each_line.with_index { |line, i| break i + 1 if /wrong number of arguments/.match?(line) }

    run_ruby(
      File.join(__dir__, "fixtures", "backtrace.rb").to_s
    ) do |_status, output, _err|
      output.should include("TRACE: #{source_path}:#{source_line}")
    end
  end
end
