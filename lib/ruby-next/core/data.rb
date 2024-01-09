# frozen_string_literal: true

# The code below originates from https://github.com/saturnflyer/polyfill-data

if !Object.const_defined?(:Data) || !Data.respond_to?(:define)

  # Drop legacy Data class
  begin
    Object.send(:remove_const, :Data)
  rescue
    nil
  end

  class Data < Object
    using RubyNext

    class << self
      undef_method :new
      attr_reader :members
    end

    def self.define(*args, &block)
      raise ArgumentError if args.any?(/=/)
      if block
        mod = Module.new
        mod.define_singleton_method(:_) do |klass|
          klass.class_eval(&block)
        end
        arity_converter = mod.method(:_)
      end
      klass = ::Class.new(self)

      klass.instance_variable_set(:@members, args.map(&:to_sym).freeze)

      klass.define_singleton_method(:new) do |*new_args, **new_kwargs, &block|
        init_kwargs = if new_args.any?
          raise ArgumentError, "unknown arguments #{new_args[members.size..].join(", ")}" if new_args.size > members.size
          members.take(new_args.size).zip(new_args).to_h
        else
          new_kwargs
        end

        allocate.tap do |instance|
          instance.send(:initialize, **init_kwargs, &block)
        end.freeze
      end

      class << klass
        alias_method :[], :new
        undef_method :define
      end

      args.each do |arg|
        if klass.method_defined?(arg)
          raise ArgumentError, "duplicate member #{arg}"
        end
        klass.define_method(arg) do
          @attributes[arg]
        end
      end

      if arity_converter
        klass.class_eval(&arity_converter)
      end

      klass
    end

    def self.inherited(subclass)
      subclass.instance_variable_set(:@members, members)
    end

    def members
      self.class.members
    end

    def initialize(**kwargs)
      kwargs_size = kwargs.size
      members_size = members.size

      if kwargs_size > members_size
        extras = kwargs.except(*members).keys

        if extras.size > 1
          raise ArgumentError, "unknown keywords: #{extras.map { ":#{_1}" }.join(", ")}"
        else
          raise ArgumentError, "unknown keyword: :#{extras.first}"
        end
      elsif kwargs_size < members_size
        missing = members.select { |k| !kwargs.include?(k) }

        if missing.size > 1
          raise ArgumentError, "missing keywords: #{missing.map { ":#{_1}" }.join(", ")}"
        else
          raise ArgumentError, "missing keyword: :#{missing.first}"
        end
      end

      @attributes = members.map { |m| [m, kwargs[m]] }.to_h
    end

    def deconstruct
      @attributes.values
    end

    def deconstruct_keys(array)
      raise TypeError unless array.is_a?(Array) || array.nil?
      return @attributes if array&.first.nil?

      @attributes.slice(*array)
    end

    def to_h(&block)
      @attributes.to_h(&block)
    end

    def hash
      to_h.hash
    end

    def eql?(other)
      self.class == other.class && hash == other.hash
    end

    def ==(other)
      self.class == other.class && to_h == other.to_h
    end

    def inspect
      attribute_markers = @attributes.map do |key, value|
        insect_key = key.to_s.start_with?("@") ? ":#{key}" : key
        "#{insect_key}=#{value}"
      end.join(", ")

      display = ["data", self.class.name, attribute_markers].compact.join(" ")

      "#<#{display}>"
    end
    alias_method :to_s, :inspect

    def with(**kwargs)
      return self if kwargs.empty?

      self.class.new(**@attributes.merge(kwargs))
    end

    private

    def marshal_dump
      @attributes
    end

    def marshal_load(attributes)
      @attributes = attributes
      freeze
    end

    def initialize_copy(source)
      super.freeze
    end
  end

end
