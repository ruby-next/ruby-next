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
      # Source: https://github.com/ruby/ruby/blob/b76a21aa45fff75909a66f8b20fc5856705f7862/struct.c#L953-L980
      def deconstruct_keys(keys)
        raise TypeError, "wrong argument type #{keys.class} (expected Array or nil)" if keys && !keys.is_a?(Array)

        return to_h unless keys

        return {} if size < keys.size

        keys.each_with_object({}) do |k, acc|
          # if k is Symbol and not a member of a Struct return {}
          next if (Symbol === k || String === k) && !members.include?(k.to_sym)
          # if k is Integer check that index is not ouf of bounds
          next if Integer === k && k > size - 1
          acc[k] = self[k]
        end
      end
    end
  end
end
