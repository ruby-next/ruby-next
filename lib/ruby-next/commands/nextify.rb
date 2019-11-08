# frozen_string_literal: true

require "fileutils"
require "pathname"

using RubyNext

module RubyNext
  module Commands
    class Nextify < Base
      attr_reader :lib_path, :min_version

      def run
        Dir[File.join(lib_path, "**/*.rb")].each do |entry|
          contents = File.read(entry)
          transpile entry, contents
        end
      end

      def parse!(args)
        optparser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby-next nextify DIRECTORY [options]"
        end

        @lib_path = args[0]

        # TODO: add options
        @min_version = MIN_SUPPORTED_VERSION

        unless lib_path&.then(&File.method(:directory?))
          $stdout.puts optparser.help
          exit 0
        end

        optparser.parse!(args)
      end

      private

      def transpile(path, contents, version: min_version)
        rewriters = Language.rewriters.select { |rw| rw.unsupported_version?(version) }

        context = Language::TransformContext.new
        new_contents = Language.transform contents, context: context, rewriters: rewriters

        return unless context.dirty?

        versions = context.sorted_versions
        version = versions.shift

        # First, store already transpiled contents in the minimum required version dir
        save new_contents, path, version

        return if versions.empty?

        # Then, generate the source code for the next version
        transpile path, contents, version: version
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
    end
  end
end
