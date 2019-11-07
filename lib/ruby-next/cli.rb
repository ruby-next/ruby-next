# frozen_string_literal: true

require "ruby-next"
require "ruby-next/language"

require "ruby-next/commands/base"
require "ruby-next/commands/nextify"

module RubyNext
  # Command line interface for RubyNext
  class CLI
    COMMANDS = {
      "nextify" => Commands::Nextify
    }.freeze

    def initialize
    end

    def run(args = ARGV)
      maybe_print_version(args)

      command = args.shift

      raise "Command must be specified!" unless command

      COMMANDS.fetch(command) do
        raise "Unknown command: #{command}. Available commands: #{COMMANDS.keys.join(",")}"
      end.run(args)
    end

    private

    def maybe_print_version(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: ruby-next COMMAND [options]"

        opts.on("-v", "--version", "Print version") do
          STDOUT.puts RubyNext::VERSION
          exit 0
        end
      end.parse!(args)
    end
  end
end
