# frozen_string_literal: true

RubyNext::Core.patch Time, method: :deconstruct_keys, version: "3.2" do
  <<-'RUBY'
def deconstruct_keys(keys)
  raise TypeError, "wrong argument type #{keys.class} (expected Array or nil)" if keys && !keys.is_a?(Array)

  if !keys
    return {
      year: year,
      month: month,
      day: day,
      yday: yday,
      wday: wday,
      hour: hour,
      min: min,
      sec: sec,
      subsec: subsec,
      dst: dst?,
      zone: zone
    }
  end

  keys.each_with_object({}) do |key, hash|
    hash[key] = public_send(key) if key.is_a?(Symbol) && respond_to?(key)
    hash
  end
end
  RUBY
end
