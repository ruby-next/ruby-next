# frozen_string_literal: true

case []
  in (1...) if x == 1
    true
  in 0, 1
    :tail
  in _, _, _
    :array
  in [*, 1, *]
    :find
  in a:, b:
    :hash
  in Object(1, 2)
    :const
  end

{a: 2} in {a:, b:}

{a: 2} => {a:, b:}
