# frozen_string_literal: true

require "open3"

module CommandTesting
  refine MSpecEnv do
    RUBY_RUNNER = if defined?(JRUBY_VERSION)
      # See https://github.com/jruby/jruby/wiki/Improving-startup-time#bundle-exec
      "jruby -G"
    else
      "bundle exec ruby"
    end

    def run(command, chdir: nil, should_fail: false, env: {})
      output, err, status =
        Open3.capture3(
          env,
          command,
          chdir: chdir || File.expand_path("../..", __dir__)
        )

      if ENV["COMMAND_DEBUG"]
        puts "\n\nCOMMAND:\n#{command}\n\nOUTPUT:\n#{output}\nERROR:\n#{err}\n"
      end

      status.success?.should == true unless should_fail

      yield status, output, err if block_given?
    end

    def run_ruby(command, **options)
      run("#{RUBY_RUNNER} -rbundler/setup -I#{File.join(__dir__, "../../lib")} #{command}", **options)
    end

    def run_ruby_next(command, **options, &block)
      run("#{RUBY_RUNNER} bin/ruby-next #{command}", **options, &block)
    end
  end
end
