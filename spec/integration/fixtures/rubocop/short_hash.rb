# frozen_string_literal: true

def short_hash(a, b)
  {a, sum: a + b, b}
end

a = 1
short_hash(a:)
