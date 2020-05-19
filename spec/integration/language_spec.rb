# frozen_string_literal: true

require_relative "../support/command_testing"

describe "language features (via -ruby-next)" do
  it "nested array pattern matching" do
    run_ruby(
      "-ruby-next -r #{File.join(__dir__, "fixtures", "nested_array.rb")} " \
      "-e 'p main([1, [2]]); p main([2, [2, 3]]); p main([1, [2, 3]])'"
    ) do |_status, output, _err|
      output.should include("2\n")
      output.should include("\"2 3\"\n")
      output.should include("\"2 [3]\"\n")
    end
  end

  it "nested hash pattern matching" do
    run_ruby(
      "-ruby-next #{File.join(__dir__, "fixtures", "display_name.rb")} "
    ) do |_status, output, _err|
      output.should include("\"Tae Noppakun Wongsrinoppakun\"\n")
      output.should include("\"Guest\"\n")
      output.should include("\"Homey Simmy\"\n")
      output.should include("\"Bart S.\"\n")
    end
  end

  it "array in hash in pattern matching" do
    run_command(
      "ruby -rbundler/setup -rjson -I#{File.join(__dir__, "../../lib")} -ruby-next #{File.join(__dir__, "fixtures", "array_in_hash_pattern.rb")} " \
      "'{\"name\":\"Alice\",\"children\":[{\"name\":\"Bob\",\"age\":30}]}'"
    ) do |_status, output, _err|
      output.should include("Bob age is 30")
    end
  end
end
