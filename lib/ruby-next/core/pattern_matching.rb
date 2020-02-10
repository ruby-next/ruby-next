# frozen_string_literal: true

# Required for pattern matching with refinements
unless defined?(NoMatchingPatternError)
  class NoMatchingPatternError < RuntimeError
  end
end

RubyNext::Core.patch Object,
  name: "NoMatchingPatternError",
  version: "2.7",
  supported: defined?(NoMatchingPatternError) do
  <<~RUBY
    class NoMatchingPatternError < RuntimeError
    end
  RUBY
end

# Add `#deconstruct` and `#deconstruct_keys` to core classes
RubyNext::Core.patch Array,
  name: "ArrayDeconstruct",
  version: "2.7",
  supported: [].respond_to?(:deconstruct) do
  <<~RUBY
    def deconstruct
      self
    end
  RUBY
end

RubyNext::Core.patch Struct,
  name: "StructDeconstruct",
  version: "2.7",
  supported: Struct.new(:x).new.respond_to?(:deconstruct_keys) do
  <<~'RUBY'
    alias deconstruct to_a

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
  RUBY
end

RubyNext::Core.patch Hash,
  name: "HashDeconstructKeys",
  version: "2.7",
  supported: {}.respond_to?(:deconstruct_keys) do
  <<~RUBY
    def deconstruct_keys(_)
      self
    end
  RUBY
end

# We need to hack `respond_to?` in Ruby 2.5, since it's not working with refinements
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
  RubyNext::Core.patch refineable: Array,
                       name: "ArrayRespondToDeconstruct",
                       version: "2.7",
                       supported: [].respond_to?(:deconstruct) do
    <<~RUBY
      def respond_to?(mid, *)
        return true if mid == :deconstruct
        super
      end
    RUBY
  end

  RubyNext::Core.patch refineable: Hash,
                       name: "HashRespondToDeconstructKeys",
                       version: "2.7",
                       supported: {}.respond_to?(:deconstruct_keys) do
    <<~RUBY
      def respond_to?(mid, *)
        return true if mid == :deconstruct_keys
        super
      end
    RUBY
  end

  RubyNext::Core.patch refineable: Struct,
                       name: "StructRespondToDeconstruct",
                       version: "2.7",
                       supported: Struct.new(:x).new.respond_to?(:deconstruct_keys) do
    <<~RUBY
      def respond_to?(mid, *)
        return true if mid == :deconstruct_keys || mid == :deconstruct
        super
      end
    RUBY
  end
end
