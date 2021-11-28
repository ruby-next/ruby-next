# frozen_string_literal: true

def short_hash(a, b)
  {a:, sum: a + b, b:} # rubocop:disable Layout/SpaceAfterColon
end

a = 1
short_hash(a:) # rubocop:disable Layout/SpaceAfterColon
