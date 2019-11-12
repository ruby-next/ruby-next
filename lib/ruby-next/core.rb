# frozen_string_literal: true

module RubyNext
  module Core
    class << self
      # Inject `using RubyNext` at the top of the source code
      def inject!(contents)
        contents.sub!(/^(\s*[^#\s].*)/, 'using RubyNext;\1')
        contents
      end
    end
  end
end

require_relative "core/kernel/then"

require_relative "core/proc/compose"

require_relative "core/enumerable/tally"
require_relative "core/enumerable/filter"

require_relative "core/array/difference_union_intersection"

require_relative "core/hash/merge"

# Core extensions required for pattern matching
require_relative "core/pattern_matching"
