# frozen_string_literal: true

# Refine Array seprately, 'cause refining modules is vulnerable to prepend:
# - https://bugs.ruby-lang.org/issues/13446
RubyNext::Core.patch Enumerable,
  name: "EnumerableFilterMap",
  version: "2.7",
  supported: [].respond_to?(:filter_map),
  refineable: [Enumerable, Array] do
  <<~RUBY
    def filter_map
      if block_given?
        result = []
        each do |element|
          res = yield element
          result << res if res
        end
        result
      else
        Enumerator.new do |yielder|
          result = []
          each do |element|
            res = yielder.yield element
            result << res if res
          end
          result
        end
      end
    end
  RUBY
end

RubyNext::Core.patch Enumerator::Lazy,
  name: "EnumeratorLazyFilterMap",
  version: "2.7",
  supported: [].respond_to?(:filter_map) do
  <<~RUBY
    def filter_map
      Enumerator::Lazy.new(self) do |yielder, *values|
        result = yield(*values)
        yielder << result if result
      end
    end
  RUBY
end
