# frozen_string_literal: true

require "fileutils"
require "pathname"

using RubyNext

module RubyNext
  module Commands
    class Nextify < Base
      RUBY_NEXT_DIR = ".rbnxt"

      attr_reader :lib_path

      def run
        Dir[File.join(lib_path, "**/*.rb")].each do |entry|
          transpile entry
        end
      end

      def parse!(args)
        optparser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby-next nextify DIRECTORY [options]"
        end

        @lib_path = args[0]

        unless lib_path&.then(&File.method(:directory?))
          $stdout.puts optparser.help
          exit 0
        end

        optparser.parse!(args)
      end

      private

      def transpile(path)
        contents = File.read(path)

        min_version = nil

        target_versions.each do |version|
          next if min_version && min_version > version

          context = Language::TransformContext.new
          rewriters = Language.rewriters.select { |rw| rw.unsupported_version?(version) }

          new_contents = Language.transform contents, context: context, rewriters: rewriters
          break unless context.dirty?

          min_version = context.min_version

          save new_contents, path, version
        end
      end

      def save(contents, path, version)
        next_path = File.join(
          lib_path,
          RUBY_NEXT_DIR,
          version.segments[0..1].join("."),
          Pathname.new(path).relative_path_from(Pathname.new(lib_path))
        )

        FileUtils.mkdir_p File.dirname(next_path)

        File.write(next_path, contents)
      end

      # TODO: make this configurable
      def target_versions
        @target_versions ||=
          [
            Gem::Version.new("2.5.0"),
            Gem::Version.new("2.6.0")
          ]
      end
    end
  end
end
