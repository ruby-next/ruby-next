# frozen_string_literal: true

require "fileutils"
require "pathname"

using RubyNext

module RubyNext
  module Commands
    class Nextify < Base
      attr_reader :lib_path, :paths, :out_path, :min_version, :single_version

      def run
        paths.each do |path|
          contents = File.read(path)
          transpile path, contents
        end
      end

      def parse!(args)
        @min_version = MIN_SUPPORTED_VERSION
        @single_version = false

        optparser = base_parser do |opts|
          opts.banner = "Usage: ruby-next nextify DIRECTORY_OR_FILE [options]"

          opts.on("-o", "--output=OUTPUT", "Specify output directory or file") do |val|
            @out_path = val
          end

          opts.on("--min-version=VERSION", "Specify the minimum Ruby version to support") do |val|
            @min_version = Gem::Version.new(val)
          end

          opts.on("--single-version", "Only create one version of a file (for the earliest Ruby version)") do
            @single_version = true
          end
        end

        @lib_path = args[0]

        unless lib_path&.then(&File.method(:exist?))
          $stdout.puts optparser.help
          exit 0
        end

        optparser.parse!(args)

        @paths =
          if File.directory?(lib_path)
            Dir[File.join(lib_path, "**/*.rb")]
          elsif File.file?(lib_path)
            [lib_path].tap do |_|
              @lib_path = File.dirname(lib_path)
            end
          end
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

        return if versions.empty? || single_version?

        # Then, generate the source code for the next version
        transpile path, contents, version: version
      end

      def save(contents, path, version)
        paths = [Pathname.new(path).relative_path_from(Pathname.new(lib_path))]

        paths.unshift(version.segments[0..1].join(".")) unless single_version?

        next_path =
          if out_path
            if out_path.end_with?(".rb")
              out_path
            else
              File.join(out_path, *paths)
            end
          else
            File.join(
              lib_path,
              RUBY_NEXT_DIR,
              *paths
            )
          end

        FileUtils.mkdir_p File.dirname(next_path)

        File.write(next_path, contents)

        log "Generated: #{next_path}"
      end

      alias single_version? single_version
    end
  end
end
