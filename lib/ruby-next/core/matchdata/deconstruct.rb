# frozen_string_literal: true

RubyNext::Core.patch MatchData, method: :deconstruct, version: "3.2" do
  <<-'RUBY'
def deconstruct
  captures.map(&:to_str)
end
  RUBY
end
