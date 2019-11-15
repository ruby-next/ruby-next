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

        unless Pathname.new(path).absolute?
          loadpath = $LOAD_PATH.find do |lp|
            File.file?(File.join(lp, path))
          end

          return if loadpath.nil?

          path = File.join(loadpath, path)
        end

        path
      end
    end

    def source_with_lines(source)
      source.lines.map.with_index do |line, i|
        "#{i.to_s.rjust(3)}:  #{line}"
      end
    end
  end
end
