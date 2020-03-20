# frozen_string_literal: true

case JSON.parse(ARGV[0], symbolize_names: true)
in {name: "Alice", children: [{name: "Bob", age: age}]}
  p "Bob age is #{age}"
in _
  "No Alice"
end
