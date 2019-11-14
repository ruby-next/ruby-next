# frozen_string_literal: true

unless [].respond_to?(:filter_map)
  module RubyNext
    module Core
      module EnumerableFilterMap
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
    end
  end

  RubyNext.module_eval do
    refine Enumerable do
      include RubyNext::Core::EnumerableFilterMap
    end

    # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
    # - https://bugs.ruby-lang.org/issues/13446
    refine Array do
      include RubyNext::Core::EnumerableFilterMap
    end
  end
end
