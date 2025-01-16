# frozen_string_literal: true

module RubyNext
  module Utils
    module_function

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
                if RUBY_VERSION >= "3.3.0"
                  import_methods(Module.new do
                    def i_am_refinement
                      "yes, you are!"
                    end
                  end)
                else
                  include(Module.new do
                    def i_am_refinement
                      "yes, you are!"
                    end
                  end)
                end
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
