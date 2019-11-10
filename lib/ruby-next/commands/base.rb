# frozen_string_literal: true

require "optparse"

module RubyNext
  module Commands
    class Base
      class << self
        def run(args)
          new(args).run
        end
      end

      def initialize(args)
        parse! args
      end

      def parse!(*)
        raise NotImplementedError
      end

      def run
        raise NotImplementedError
      end

      def log(msg)
        return unless CLI.verbose
        $stdout.puts msg
      end

      def base_parser
        OptionParser.new do |opts|
          yield opts

          opts.on("-V", "Turn on verbose mode") do
            CLI.verbose = true
          end
        end
      end
    end
  end
end
