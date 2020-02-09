# frozen_string_literal: true

unless [].respond_to?(:union)
  RubyNext::Core.patch Array, name: "ArrayUnion" do
    def union(*others)
      others.reduce(Array.new(self).uniq) { |acc, arr| acc | arr }
    end
  end
end

unless [].respond_to?(:difference)
  RubyNext::Core.patch Array, name: "ArrayDifference" do
    def difference(*others)
      others.reduce(Array.new(self)) { |acc, arr| acc - arr }
    end
  end
end

unless [].respond_to?(:intersection)
  RubyNext::Core.patch Array, name: "ArrayIntersection" do
    def intersection(*others)
      others.reduce(Array.new(self)) { |acc, arr| acc & arr }
    end
  end
end
