# frozen_string_literal: true

# Make sure Core is loaded
require "ruby-next"

module RubyNext
  module Language
    class << self
      unless method_defined?(:runtime?)
        def runtime?
          false
        end
      end

      def setup_gem_load_path(lib_dir = "lib", rbnext_dir: RUBY_NEXT_DIR)
        called_from = caller_locations(1, 1).first.path
        dirname = File.dirname(called_from)

        loop do
          basename = File.basename(dirname)
          raise "Couldn't find gem's load dir: #{lib_dir}" if basename == dirname

          break if basename == lib_dir

          dirname = File.dirname(basename)
        end

        dirname = File.realpath(dirname)

        return if Language.runtime? && Language.watch_dirs.include?(dirname)

        current_index = $LOAD_PATH.index(dirname)

        raise "Gem's lib is not in the $LOAD_PATH: #{dirname}" if current_index.nil?

        version = RubyNext.next_version

        loop do
          break unless version

          version_dir = File.join(dirname, rbnext_dir, version.segments[0..1].join("."))

          if File.exist?(version_dir)
            $LOAD_PATH.insert current_index, version_dir
            current_index += 1
          end

          version = RubyNext.next_version(version)
        end
      end
    end
  end
end
