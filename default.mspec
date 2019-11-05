# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

begin
  require "pry-byebug"
rescue LoadError
  nil
end

require "ruby-next/runtime"
