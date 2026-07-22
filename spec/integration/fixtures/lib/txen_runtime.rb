# frozen_string_literal: true

require "ruby-next/language"
# Use deprecated `#watch_dirs` here intentionally to test that it still works
RubyNext::Language.watch_dirs << __dir__
require "ruby-next/language/runtime"

require "txen"
