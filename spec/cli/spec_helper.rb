# frozen_string_literal: true

require "open3"

module CliTesting
  refine Kernel do
    def run_cli(command, opt_string = "", chdir: nil, should_fail: false)
      output, err, status =
        Open3.capture3(
          "bundle exec #{command} #{opt_string}",
          chdir: chdir || File.expand_path("../..", __dir__)
        )

      err.should be_empty unless should_fail
      yield status, output, err
    end
  end
end
