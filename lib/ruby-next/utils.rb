# frozen_string_literal: true

module RubyNext
  module Utils
    module_function

    if $LOAD_PATH.respond_to?(:resolve_feature_path)
      def resolve_feature_path(feature)
        $LOAD_PATH.resolve_feature_path(feature)&.last
      rescue LoadError
      end
    else
      def resolve_feature_path(path)
        if File.file?(relative = File.expand_path(path))
          path = relative
        end

        path = "#{path}.rb" if File.extname(path).empty?

        return path if Pathname.new(path).absolute?

        $LOAD_PATH.find do |lp|
          lpath = File.join(lp, path)
          return File.realpath(lpath) if File.file?(lpath)
        end
      end
    end

    def source_with_lines(source, path)
      source.lines.map.with_index do |line, i|
        "#{(i + 1).to_s.rjust(4)}:  #{line}"
      end.tap do |lines|
        lines.unshift "   0:  # source: #{path}"
      end
    end

    # Returns true if modules refinement is supported in current version
    def refine_modules?
      @refine_modules ||=
        begin
          Module.new { refine Kernel do; end }
          true
        rescue TypeError
          false
        end
    end
  end
end
