# frozen_string_literal: true

unless [].respond_to?(:filter_map)
  # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
  # - https://bugs.ruby-lang.org/issues/13446
  RubyNext::Core.patch Enumerable, name: "EnumerableFilterMap", refineable: [Enumerable, Array] do
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
  end

  RubyNext::Core.patch Enumerator::Lazy, name: "EnumeratorLazyFilterMap" do
    def filter_map
      Enumerator::Lazy.new(self) do |yielder, *values|
        result = yield(*values)
        yielder << result if result
      end
    end
  end
end
