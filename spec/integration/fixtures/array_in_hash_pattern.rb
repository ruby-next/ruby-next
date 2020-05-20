# frozen_string_literal: true

def main(val)
  case JSON.parse(val, symbolize_names: true)
  in {name: "Alice", children: [{name: "Bob", age: age}]}
    p "Bob age is #{age}"
  in _
    p "No Alice"
  end
end

main(ARGV[0]) if ARGV[0]
