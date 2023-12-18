# frozen_string_literal: true

RubyNext::Core.patch MatchData, method: :deconstruct_keys, version: "3.2" do
  <<-'RUBY'
def deconstruct_keys(keys)
  raise TypeError, "wrong argument type #{keys.class} (expected Array)" if keys && !keys.is_a?(Array)

  captured = named_captures.transform_keys!(&:to_sym)
  return captured if keys.nil?

  return {} if keys.size > captured.size

  keys.each_with_object({}) do |k, acc|
    raise TypeError, "wrong argument type #{k.class} (expected Symbol)" unless Symbol === k
    return acc unless captured.key?(k)
    acc[k] = self[k]
  end
end
  RUBY
end
