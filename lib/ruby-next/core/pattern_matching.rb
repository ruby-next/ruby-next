# frozen_string_literal: true

unless defined?(NoMatchingPatternError)
  class NoMatchingPatternError < RuntimeError
  end
end

# Add `#deconstruct` and `#deconstruct_keys` to core classes
unless [].respond_to?(:deconstruct)
  RubyNext.module_eval do
    refine Array do
      def deconstruct
        self
      end
    end

    refine Struct do
      alias deconstruct to_a
    end
  end
end

unless {}.respond_to?(:deconstruct_keys)
  RubyNext.module_eval do
    refine Hash do
      def deconstruct_keys(_)
        self
      end
    end

    refine Struct do
      def deconstruct_keys(_)
        to_h
      end
    end
  end
end
