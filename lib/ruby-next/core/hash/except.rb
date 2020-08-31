# frozen_string_literal: true

RubyNext::Core.patch Hash, method: :except, version: "2.8" do
  <<-RUBY
def except(*keys)
  self.dup.tap do |new_hash|
    keys.each { |k| new_hash.delete(k) }
  end
end
  RUBY
end
