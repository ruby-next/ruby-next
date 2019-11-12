# frozen_string_literal: true

require "open3"

module CommandTesting
  refine Kernel do
    def run(command, opt_string = "", chdir: nil, should_fail: false)
      output, err, status =
        Open3.capture3(
          "bundle exec #{command} #{opt_string}",
          chdir: chdir || File.expand_path("../..", __dir__)
        )

      status.success?.should == true unless should_fail
      if ENV["CLI_DEBUG"]
        puts "\n\nCOMMAND:\n#{command} #{opt_string}\n\nOUTPUT:\n#{output}\nERROR:\n#{err}\n"
      end
      yield status, output, err if block_given?
    end
  end
end
