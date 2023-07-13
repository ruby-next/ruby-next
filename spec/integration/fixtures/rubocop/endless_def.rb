# frozen_string_literal: true

class Ende
  def self.version() = "1.0"

  def greet(val) =
    case val
    in hello: hello if hello =~ /human/
      puts "human"
    in hello: "martian"
      puts "alien"
    end
end
