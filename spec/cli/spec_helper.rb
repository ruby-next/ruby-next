# frozen_string_literal: true

require "open3"

module CliTesting
  refine Kernel do
    def run_cli(command, opt_string = "", chdir: nil)
      output, err, status = Open3.capture3(
        "bundle exec #{command} #{opt_string}",
        chdir: chdir || File.expand_path("../../bin", __dir__)
      )

      yield status, output, err
    end
  end
end
