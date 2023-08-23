# frozen_string_literal: true

require "bootsnap"
Bootsnap.setup(
  cache_dir: File.join(__dir__, "tmp/cache"),
  development_mode: false,
  load_path_cache: true,
  compile_cache_iseq: true,
  compile_cache_yaml: true
)

require "ruby-next/language/runtime"
RubyNext::Language.include_patterns << File.join(__dir__, ".rb")

require_relative "pattern"

puts main('{"command": "perform", "channel": "ruby_next", "action": "test"}')
puts main('{"command": "perform", "channel": "bootsnap"}')
