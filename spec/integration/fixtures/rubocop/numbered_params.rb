# frozen_string_literal: true

proc { _1 + _2 }

[1, 2].map do
  _1 * 2
end

-> { _1 }
