# frozen_string_literal: true

unless [].respond_to?(:tally)
  module RubyNext
    module Core
      module EnumerableTally
        def tally
          each_with_object({}) do |v, acc|
            acc[v] ||= 0
            acc[v] += 1
          end
        end
      end
    end
  end

  RubyNext.module_eval do
    refine Enumerable do
      include RubyNext::Core::EnumerableTally
    end

    # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
    # - https://bugs.ruby-lang.org/issues/13446
    refine Array do
      include RubyNext::Core::EnumerableTally
    end
  end
end
