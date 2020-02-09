# frozen_string_literal: true

require "set"

module RubyNext
  module Core
    # Patch contains the extension implementation
    # and meta information (e.g., Ruby version).
    class Patch
      attr_reader :refineables, :name, :mod, :block

      # Create a new patch for module/class (mod)
      # with the specified uniq name
      def initialize(mod, name:, refineable: mod, &block)
        @mod = mod
        @name = name
        @refineables = Array(refineable)
        @block = block
      end

      alias to_proc block
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
        @extensions[patch.mod] << patch
        patch.refineables.each { |r| @refined[r] << patch }
      end
    end

    class << self
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
        module_eval(&patch)
      end
    end
  end
end
