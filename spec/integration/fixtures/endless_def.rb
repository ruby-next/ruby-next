# frozen_string_literal: true

def greet(val) =
  case val
  in hello: hello if hello =~ /human/i
    puts "human"
  in hello: "martian"
    puts "alien"
  end

# p greet(hello: "Human") => 'human'
# p greet(hello: "martian") => 'alien'
