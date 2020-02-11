# frozen_string_literal: true

if ENV["CORE_EXT"] == "gem"
  require "ruby-next/core_ext"
else
  require "ruby-next"
  using RubyNext
end

begin
  Enumerator.produce(1, 2)
rescue ArgumentError => e
  puts "TRACE: #{e.backtrace.first}"
end
