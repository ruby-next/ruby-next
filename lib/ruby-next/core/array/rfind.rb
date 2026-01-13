# frozen_string_literal: true

RubyNext::Core.patch Array, method: :rfind, version: "4.0" do
  <<-RUBY
def rfind(ifnone = nil)
  unless block_given?
    array = self

    return Enumerator.new(size) do |yielder|
      found = nil
      matched = false

      array.reverse_each do |element|
        if yielder.yield(element)
          found = element
          matched = true
          break
        end
      end

      matched ? found : ifnone&.call
    end
  end

  reverse_each do |element|
    return element if yield(element)
  end

  ifnone&.call
end
  RUBY
end
