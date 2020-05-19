# frozen_string_literal: true

require "open3"

module Kernel
  RUBY_RUNNER = if defined?(JRUBY_VERSION)
    # See https://github.com/jruby/jruby/wiki/Improving-startup-time#bundle-exec
    "jruby -G"
  else
    "bundle exec ruby"
  end

  def run_command(command, chdir: nil, should_fail: false, env: {})
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

  def run_ruby(command, **options, &block)
    run_command("#{RUBY_RUNNER} -rbundler/setup -I#{File.join(__dir__, "../../lib")} #{command}", **options, &block)
  end

  def run_ruby_next(command, **options, &block)
    run_command("#{RUBY_RUNNER} #{File.join(__dir__, "../../bin/ruby-next")} #{command}", **options, &block)
  end
end
