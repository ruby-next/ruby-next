# frozen_string_literal: true

require_relative "../support/command_testing"

describe "ruby -ruby-next" do
  it "transform code in runtime when it's required" do
    run_ruby(
      "-ruby-next -r #{File.join(__dir__, "fixtures", "beach.rb")} " \
      "-e 'puts beach(:k, 300)'"
    ) do |_status, output, _err|
      output.should include("scientifically_favorable")
    end
  end

  it "catches compile error for scripts and re-run them" do
    run_ruby(
      "-ruby-next #{File.join(__dir__, "fixtures", "beach.rb")} k 10000"
    ) do |_status, output, _err|
      output.should include("burning_on_the_sun")
    end
  end

  it "handles multiline code" do
    run_ruby(
      <<~CMD
        -ruby-next -e '
          p case [1, 2]
            in [*, 2]
              :ok
          end
          '
    CMD
    ) do |_status, output, _err|
      output.should include("ok")
    end
  end

  it "proposed features" do
    cmd = <<~CMD
      ruby -rbundler/setup -I#{File.join(__dir__, "../../../lib")} -ruby-next -r #{File.join(__dir__, "fixtures", "method_reference.rb")} \
      -e "p main({}.to_json); p main({status: :ok}.to_json)"
    CMD

    # Set env var to 0 to make sure we do not shadow it
    run_command(cmd, env: {"RUBY_NEXT_PROPOSED" => "0"}) do |_status, output, _err|
      output.should include("\"status: \"\n")
      output.should include("\"status: ok\"\n")
    end
  end

  it "edge features" do
    cmd = <<~CMD
      ruby -rbundler/setup -I#{File.join(__dir__, "../../../lib")} -ruby-next -r #{File.join(__dir__, "fixtures", "endless_def.rb")} \
      -e "p greet(hello: 'Human'); p greet(hello: 'martian')"
    CMD

    # Set env var to 0 to make sure we do not shadow it
    run_command(cmd, env: {"RUBY_NEXT_EDGE" => "0"}) do |_status, output, _err|
      output.should include("human\n")
      output.should include("alien\n")
    end
  end
end
