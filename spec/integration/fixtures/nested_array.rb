def main(data)
  case data
  in a, [b]
    b
  in 2, [b, c]
    "#{b} #{c}"
  in 1, [b, *rest]
    "#{b} #{rest}"
  end
end

# p main [1, [2]] #=> 2
# p main [2, [2, 3]] #=> "2 3"
# p main [1, [2, 3]] #=> "2 [3]"
