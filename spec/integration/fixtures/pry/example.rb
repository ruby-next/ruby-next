# frozen_string_literal: true

# An example of a file with missing "using RubyNext"

h1 = {"a" => 100, "b" => 200}
h2 = {"b" => 254, "c" => 300}
h1.merge(h2)

[0, 1, 2, 3].intersection([0, 1, 2], [0, 1, 3])

hash = {a: true, b: false, c: nil}
hash.except(:a, :b)
