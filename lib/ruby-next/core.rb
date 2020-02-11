# frozen_string_literal: true

require "set"

module RubyNext
  module Core
    # Patch contains the extension implementation
    # and meta information (e.g., Ruby version).
    class Patch
      attr_reader :refineables, :name, :mod, :version, :body, :singleton, :core_ext, :supported, :location

      # Create a new patch for module/class (mod)
      # with the specified uniq name
      #
      # `core_ext` defines the strategy for core extensions:
      #    - :patch — extend class directly
      #    - :prepend — extend class by prepending a module (e.g., when needs `super`)
      def initialize(mod = nil, name:, version:, supported:, location: nil, refineable: mod, core_ext: :patch, singleton: nil)
        @mod = mod
        @name = name
        @version = version
        @supported = supported
        @singleton = singleton
        @refineables = Array(refineable)
        @body = yield
        @core_ext = core_ext
        @location = location
      end

      def prepend?
        core_ext == :prepend
      end

      def core_ext?
        !mod.nil?
      end

      alias supported? supported
      alias singleton? singleton

      def to_module
        Module.new.tap do |ext|
          ext.module_eval(body, *location)

          RubyNext::Core.const_set(name, ext)
        end
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
        patch.refineables.each { |r| @refined[r] << patch } unless patch.supported?
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

# Core extensions required for pattern matching
require_relative "core/pattern_matching"

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
