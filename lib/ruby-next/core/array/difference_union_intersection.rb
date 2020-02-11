# frozen_string_literal: true

RubyNext::Core.patch Array,
  name: "ArrayUnion",
  version: "2.6",
  supported: [].respond_to?(:union),
  location: [__FILE__, __LINE__ + 2] do
  <<~RUBY
    def union(*others)
      others.reduce(Array.new(self).uniq) { |acc, arr| acc | arr }
    end
  RUBY
end

RubyNext::Core.patch Array,
  name: "ArrayDifference",
  version: "2.6",
  supported: [].respond_to?(:difference),
  location: [__FILE__, __LINE__ + 2] do
  <<~RUBY
    def difference(*others)
      others.reduce(Array.new(self)) { |acc, arr| acc - arr }
    end
  RUBY
end

RubyNext::Core.patch Array,
  name: "ArrayIntersection",
  version: "2.7",
  supported: [].respond_to?(:intersection),
  location: [__FILE__, __LINE__ + 2] do
  <<~RUBY
    def intersection(*others)
      others.reduce(Array.new(self)) { |acc, arr| acc & arr }
    end
  RUBY
end
