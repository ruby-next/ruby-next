# frozen_string_literal: true

module RubyNext
  module Utils
    module_function

    def lookup_feature_path(path, implitic_ext: true)
      path = "#{path}.rb" if File.extname(path).empty? && implitic_ext

      # Resolve relative paths only against current directory
      if path.match?(/^\.\.?\//)
        path = File.expand_path(path)
        return path if File.file?(path)
        return nil
      end

      if Pathname.new(path).absolute?
        path = File.expand_path(path)
        return File.file?(path) ? path : nil
      end

      # not a relative, not an absolute path — bare path; try looking relative to current dir,
      # if it's in the $LOAD_PATH
      if $LOAD_PATH.include?(Dir.pwd) && File.file?(path)
        return File.expand_path(path)
      end

      $LOAD_PATH.find do |lp|
        lpath = File.join(lp, path)
        return File.expand_path(lpath) if File.file?(lpath)
      end
    end

    if $LOAD_PATH.respond_to?(:resolve_feature_path)
      def resolve_feature_path(feature, implitic_ext: true)
        if implitic_ext
          $LOAD_PATH.resolve_feature_path(feature)&.last
        else
          lookup_feature_path(feature, implitic_ext: implitic_ext)
        end
      rescue LoadError
      end
    else
      def resolve_feature_path(feature, implitic_ext: true)
        lookup_feature_path(feature, implitic_ext: implitic_ext)
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
      save_verbose, $VERBOSE = $VERBOSE, nil
      @refine_modules ||=
        begin
          # Make sure that including modules within refinements works
          # See https://github.com/oracle/truffleruby/issues/2026
          eval <<~RUBY, TOPLEVEL_BINDING, __FILE__, __LINE__ + 1
            module RubyNext::Utils::A; end
            class RubyNext::Utils::B
              include RubyNext::Utils::A
            end

            using(Module.new do
              refine RubyNext::Utils::A do
                include(Module.new do
                  def i_am_refinement
                    "yes, you are!"
                  end
                end)
              end
            end)

            RubyNext::Utils::B.new.i_am_refinement
          RUBY
          true
        rescue TypeError, NoMethodError
          false
        ensure
          $VERBOSE = save_verbose
        end
    end
  end
end
