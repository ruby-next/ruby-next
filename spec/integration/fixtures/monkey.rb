# frozen_string_literal: true

class Struct
  def deconstruct_keys(_)
    to_h
  end
end

require "ruby-next"

using RubyNext

obj = Struct.new(:a, :b).new(1, 2)

puts "RESULT: #{obj.deconstruct_keys([:a])}"
