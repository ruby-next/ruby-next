# frozen_string_literal: true

require "ruby-next/language"
require "ruby-next/language/rewriters/edge"

require "ruby-next/language/runtime"
# Use deprecated `#watch_dirs` here intentionally to test that it still works
RubyNext::Language.watch_dirs << __dir__
require "txen"
