# frozen_string_literal: true

# Load rewriters only required for runtime transpiling

require "ruby-next/language/rewriters/runtime/dir"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::Dir
