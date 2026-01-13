# frozen_string_literal: true

if ENV["CORE_EXT"] == "gem"
  require "ruby-next/core_ext"
else
  require "ruby-next"
  using RubyNext
end

begin
  "".strip(1, 2)
rescue TypeError => e
  puts e.message
  puts "TRACE: #{e.backtrace.first}"
end
