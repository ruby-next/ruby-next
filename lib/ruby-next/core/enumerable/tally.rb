# frozen_string_literal: true

unless [].respond_to?(:tally)
  # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
  # - https://bugs.ruby-lang.org/issues/13446
  RubyNext::Core.patch Enumerable, name: "Enumerable", refineable: [Enumerable, Array] do
    def tally
      each_with_object({}) do |v, acc|
        acc[v] ||= 0
        acc[v] += 1
      end
    end
  end
end
