# frozen_string_literal: true

module RubyNext
  module Utils
    module_function

    if $LOAD_PATH.respond_to?(:resolve_feature_path)
      def resolve_feature_path(feature)
        $LOAD_PATH.resolve_feature_path(feature)&.last
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
          return lpath if File.file?(lpath)
        end
      end
    end

    def source_with_lines(source)
      source.lines.map.with_index do |line, i|
        "#{i.to_s.rjust(3)}:  #{line}"
      end
    end
  end
end
