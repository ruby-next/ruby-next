# frozen_string_literal: true

require_relative "../support/command_testing"

using CommandTesting

describe "patch has source location meta" do
  it "works" do
    skip if RUBY_VERSION >= "2.7"

    source_path = Pathname.new(File.join(__dir__, "../../lib/ruby-next/core/enumerator/produce.rb")).realpath
    source_line = File.open(source_path).each_line.with_index { |line, i| break i + 1 if /wrong number of arguments/.match?(line) }

    run(
      "ruby -rbundler/setup -I#{File.join(__dir__, "../../lib")} "\
      "#{File.join(__dir__, "fixtures", "backtrace.rb")}"
    ) do |_status, output, _err|
      output.should include("TRACE: #{source_path}:#{source_line}")
    end
  end
end
