# frozen_string_literal: true

unless [].respond_to?(:union)
  RubyNext.module_eval do
    refine Array do
      def union(*others)
        others.reduce(Array.new(self).uniq) { |acc, arr| acc | arr }
      end
    end
  end
end

unless [].respond_to?(:difference)
  RubyNext.module_eval do
    refine Array do
      def difference(*others)
        others.reduce(Array.new(self)) { |acc, arr| acc - arr }
      end
    end
  end
end

unless [].respond_to?(:intersection)
  RubyNext.module_eval do
    refine Array do
      def intersection(*others)
        others.reduce(Array.new(self)) { |acc, arr| acc & arr }
      end
    end
  end
end
