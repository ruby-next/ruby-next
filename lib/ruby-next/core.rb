# frozen_string_literal: true

require "set"

module RubyNext
  module Core
    # Patch contains the extension implementation
    # and meta information (e.g., Ruby version).
    class Patch
      attr_reader :refineables, :name, :mod, :method_name, :version, :body, :singleton, :core_ext, :supported, :native, :location

      # Create a new patch for module/class (mod)
      # with the specified uniq name
      #
      # `core_ext` defines the strategy for core extensions:
      #    - :patch — extend class directly
      #    - :prepend — extend class by prepending a module (e.g., when needs `super`)
      def initialize(mod = nil, method:, name: nil, version:, supported: nil, native: nil, location: nil, refineable: mod, core_ext: :patch, singleton: nil)
        @mod = mod
        @method_name = method
        @version = version
        if method_name && mod
          @supported = supported.nil? ? mod.method_defined?(method_name) : supported
          # define whether running Ruby has a native implementation for this method
          # for that, we check the source_location (which is nil for C defined methods)
          @native = native.nil? ? (supported? && mod.instance_method(method_name).source_location.nil?) : native
        end
        @singleton = singleton
        @refineables = Array(refineable)
        @body = yield
        @core_ext = core_ext
        @location = location || build_location(caller_locations(1, 5))
        @name = name || build_module_name
      end

      def prepend?
        core_ext == :prepend
      end

      def core_ext?
        !mod.nil?
      end

      alias supported? supported
      alias native? native
      alias singleton? singleton

      def to_module
        Module.new.tap do |ext|
          ext.module_eval(body, *location)

          RubyNext::Core.const_set(name, ext)
        end
      end

      private

      def build_module_name
        mod_name = singleton? ? singleton.name : mod.name
        camelized_method_name = method_name.to_s.split("_").map(&:capitalize).join

        "#{mod_name}#{camelized_method_name}".gsub(/\W/, "")
      end

      def build_location(trace_locations)
        # The caller_locations behaviour depends on implementaion,
        # e.g. in JRuby https://github.com/jruby/jruby/issues/6055
        while trace_locations.first.label != "patch"
          trace_locations.shift
        end

        trace_location = trace_locations[1]

        [trace_location.absolute_path, trace_location.lineno + 2]
      end
    end

    # Registry for patches
    class Patches
      attr_reader :extensions, :refined

      def initialize
        @names = Set.new
        @extensions = Hash.new { |h, k| h[k] = [] }
        @refined = Hash.new { |h, k| h[k] = [] }
      end

      # Register new patch
      def <<(patch)
        raise ArgumentError, "Patch already registered: #{patch.name}" if @names.include?(patch.name)
        @names << patch.name
        @extensions[patch.mod] << patch if patch.core_ext?
        patch.refineables.each { |r| @refined[r] << patch } unless patch.native?
      end
    end

    class << self
      STRATEGIES = %i[refine core_ext].freeze

      attr_reader :strategy

      def strategy=(val)
        raise ArgumentError, "Unknown strategy: #{val}. Available: #{STRATEGIES.join(",")}" unless STRATEGIES.include?(val)
        @strategy = val
      end

      def refine?
        strategy == :refine
      end

      def core_ext?
        strategy == :core_ext
      end

      def patch(*args, **kwargs, &block)
        patches << Patch.new(*args, **kwargs, &block)
      end

      # Inject `using RubyNext` at the top of the source code
      def inject!(contents)
        if contents.frozen?
          contents = contents.sub(/^(\s*[^#\s].*)/, 'using RubyNext;\1')
        else
          contents.sub!(/^(\s*[^#\s].*)/, 'using RubyNext;\1')
        end
        contents
      end

      def patches
        @patches ||= Patches.new
      end
    end

    # Use refinements by default
    self.strategy = :refine
  end
end

require_relative "core/kernel/then"

require_relative "core/proc/compose"

require_relative "core/enumerable/tally"
require_relative "core/enumerable/filter"
require_relative "core/enumerable/filter_map"

require_relative "core/enumerator/produce"

require_relative "core/array/difference_union_intersection"

require_relative "core/hash/merge"

require_relative "core/string/split"

require_relative "core/symbol/start_with"
require_relative "core/symbol/end_with"

require_relative "core/unboundmethod/bind_call"

require_relative "core/time/floor"
require_relative "core/time/ceil"

# Core extensions required for pattern matching
# Required for pattern matching with refinements
unless defined?(NoMatchingPatternError)
  class NoMatchingPatternError < RuntimeError
  end
end

require_relative "core/constants/no_matching_pattern_error"
require_relative "core/array/deconstruct"
require_relative "core/hash/deconstruct_keys"
require_relative "core/struct/deconstruct"
require_relative "core/struct/deconstruct_keys"

# Generate refinements
RubyNext.module_eval do
  RubyNext::Core.patches.refined.each do |mod, patches|
    refine mod do
      patches.each do |patch|
        module_eval(patch.body, *patch.location)
      end
    end
  end
end
