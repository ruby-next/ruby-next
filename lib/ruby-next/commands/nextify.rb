# frozen_string_literal: true

require "fileutils"
require "pathname"

require "ruby-next/language"

module RubyNext
  module Commands
    class Nextify < Base
      using RubyNext

      class Stats
        def initialize
          @started_at = ::Process.clock_gettime(Process::CLOCK_MONOTONIC)
          @files = 0
          @scans = 0
          @transpiled_files = 0
        end

        def file!
          @files += 1
        end

        def scan!
          @scans += 1
        end

        def transpiled!
          @transpiled_files += 1
        end

        def report
          <<~TXT

            Files processed: #{@files}
            Total scans: #{@scans}
            Files transpiled: #{@transpiled_files}

            Completed in #{::Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at}s
          TXT
        end
      end

      attr_reader :lib_path, :paths, :out_path, :min_version, :single_version, :specified_rewriters, :overwrite
      alias_method :overwrite?, :overwrite
      attr_reader :stats

      def run
        @stats = Stats.new

        log "RubyNext core strategy: #{RubyNext::Core.strategy}"
        log "RubyNext transpile mode: #{RubyNext::Language.mode}"

        remove_rbnext!

        @min_version ||= MIN_SUPPORTED_VERSION

        paths.each do |path|
          stats.file!

          contents = File.read(path)
          transpile path, contents
        end

        ensure_rbnext!

        log stats.report
      end

      def parse!(args)
        print_help = false
        print_rewriters = false
        rewriter_names = []
        custom_rewriters = []
        @single_version = false
        @overwrite = false

        optparser = base_parser do |opts|
          opts.banner = "Usage: ruby-next nextify DIRECTORY_OR_FILE [options]"

          opts.on("-o", "--output=OUTPUT", "Specify output directory or file or stdout") do |val|
            @out_path = val
          end

          opts.on("--min-version=VERSION", "Specify the minimum Ruby version to support") do |val|
            @min_version = Gem::Version.new(val)
          end

          opts.on("--single-version", "Only create one version of a file (for the earliest Ruby version)") do
            @single_version = true
          end

          opts.on("--overwrite", "Overwrite original file") do
            @overwrite = true
          end

          opts.on("--edge", "Enable edge (master) Ruby features") do |val|
            ENV["RUBY_NEXT_EDGE"] = val.to_s
            require "ruby-next/language/rewriters/edge"
          end

          opts.on("--proposed", "Enable proposed/experimental Ruby features") do |val|
            ENV["RUBY_NEXT_PROPOSED"] = val.to_s
            require "ruby-next/language/rewriters/proposed"
          end

          opts.on(
            "--transpile-mode=MODE",
            "Transpiler mode (ast or rewrite). Default: rewrite"
          ) do |val|
            Language.mode = val.to_sym
          end

          opts.on("--[no-]refine", "Do not inject `using RubyNext`") do |val|
            Core.strategy = :core_ext unless val
          end

          opts.on("--list-rewriters", "List available rewriters") do |val|
            print_rewriters = true
          end

          opts.on("--rewrite=REWRITERS...", "Specify particular Ruby features to rewrite") do |val|
            rewriter_names << val
          end

          opts.on("--import-rewriter=REWRITERS...", "Specify paths to load custom rewritiers") do |val|
            custom_rewriters << val
          end

          opts.on("-h", "--help", "Print help") do
            print_help = true
          end
        end

        optparser.parse!(args)

        @lib_path = args[0]

        if print_help
          $stdout.puts optparser.help
          exit 0
        end

        # Load custom rewriters
        custom_rewriters.each do |path|
          Kernel.load path
        end

        if print_rewriters
          Language.rewriters.each do |rewriter|
            $stdout.puts "#{rewriter::NAME} (\"#{rewriter::SYNTAX_PROBE}\")#{rewriter.unsupported_syntax? ? " (unsupported)" : ""}"
          end
          exit 0
        end

        unless lib_path&.then(&File.method(:exist?))
          $stdout.puts "Path not found: #{lib_path}"
          $stdout.puts optparser.help
          exit 2
        end

        if rewriter_names.any? && min_version
          $stdout.puts "--rewrite cannot be used with --min-version simultaneously"
          exit 2
        end

        @specified_rewriters =
          if rewriter_names.any?
            begin
              Language.select_rewriters(*rewriter_names)
            rescue Language::RewriterNotFoundError => error
              $stdout.puts error.message
              $stdout.puts "Try --list-rewriters to see list of available rewriters"
              exit 2
            end
          end

        if overwrite? && !single_version?
          $stdout.puts "--overwrite only works with --single-version or explcit rewritires specified (via --rewrite)"
          exit 2
        end

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
        stats.scan!

        rewriters = specified_rewriters || Language.rewriters.select { |rw| rw.unsupported_version?(version) }

        context = Language::TransformContext.new(path: path)

        new_contents = Language.transform contents, context: context, rewriters: rewriters

        return unless context.dirty?

        versions = context.sorted_versions
        version = versions.shift

        # First, store already transpiled contents in the minimum required version dir
        save new_contents, path, version

        return if versions.empty? || single_version?

        # Then, generate the source code for the next version
        transpile path, contents, version: version
      rescue SyntaxError, StandardError => e
        warn "Failed to transpile #{path}: #{e.class} — #{e.message}"
        warn e.backtrace.take(10).join("\n") if ENV["RUBY_NEXT_DEBUG"] == "1"
        exit 1
      end

      def save(contents, path, version)
        stats.transpiled!

        return $stdout.puts(contents) if stdout?

        paths = [Pathname.new(path).relative_path_from(Pathname.new(lib_path))]

        paths.unshift(version.segments[0..1].join(".")) unless single_version?

        if overwrite?
          overwrite_file_content!(path: path, contents: contents)

          return
        end

        next_path =
          if next_dir_path.end_with?(".rb")
            out_path
          else
            File.join(next_dir_path, *paths)
          end

        unless CLI.dry_run?
          FileUtils.mkdir_p File.dirname(next_path)

          File.write(next_path, contents)
        end

        log "Generated: #{next_path}"
      end

      def overwrite_file_content!(path:, contents:)
        unless CLI.dry_run?
          File.write(path, contents)
        end

        log "Overwritten: #{path}"
      end

      def remove_rbnext!
        return if CLI.dry_run? || stdout?

        return unless File.directory?(next_dir_path)

        log "Remove old files: #{next_dir_path}"
        FileUtils.rm_r(next_dir_path)
      end

      def ensure_rbnext!
        return if CLI.dry_run? || stdout?

        return if File.directory?(next_dir_path)

        return if next_dir_path.end_with?(".rb")

        return if overwrite?

        FileUtils.mkdir_p next_dir_path
        File.write(File.join(next_dir_path, ".keep"), "")
      end

      def next_dir_path
        @next_dir_path ||= out_path || File.join(lib_path, RUBY_NEXT_DIR)
      end

      def stdout?
        out_path == "stdout"
      end

      def single_version?
        single_version || specified_rewriters
      end
    end
  end
end
