# frozen_string_literal: true

RubyNext::Core.patch Time, method: :ceil, version: "2.7" do
  <<~'RUBY'
    def ceil(den = 0)
      change = subsec.ceil(den) - subsec
      self + change
    end
  RUBY
end
