# frozen_string_literal: true

require "open3"

module CommandTesting
  refine MSpecEnv do
    def run(command, opt_string = "", chdir: nil, should_fail: false, env: {})
      output, err, status =
        Open3.capture3(
          env,
          "bundle exec #{command} #{opt_string}",
          chdir: chdir || File.expand_path("../..", __dir__)
        )

      if ENV["CLI_DEBUG"]
        puts "\n\nCOMMAND:\n#{command} #{opt_string}\n\nOUTPUT:\n#{output}\nERROR:\n#{err}\n"
      end

      status.success?.should == true unless should_fail

      yield status, output, err if block_given?
    end
  end
end
