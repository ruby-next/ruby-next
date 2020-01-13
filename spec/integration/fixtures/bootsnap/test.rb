# frozen_string_literal: true

require "bootsnap"
Bootsnap.setup(
  cache_dir: File.join(__dir__, "tmp/cache"),
  development_mode: false,
  load_path_cache: true,
  autoload_paths_cache: false,
  compile_cache_iseq: true,
  compile_cache_yaml: true
)

require "ruby-next/language/bootsnap"
RubyNext::Language.watch_dirs << __dir__

require_relative "pattern"

puts main(%q({"command": "perform", "channel": "ruby_next", "action": "test"}))
puts main(%q({"command": "perform", "channel": "bootsnap"}))
