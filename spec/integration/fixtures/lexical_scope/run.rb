# frozen_string_literal: true


require "ruby-next/language/runtime"
RubyNext::Language.watch_dirs << __dir__

require_relative "refine"
require_relative "main"

Test.call
