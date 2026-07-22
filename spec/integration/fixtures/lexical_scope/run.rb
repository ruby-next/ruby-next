# frozen_string_literal: true

require "ruby-next/language"
RubyNext::Language.include_patterns << File.join(__dir__, ".rb")
require "ruby-next/language/runtime"

require_relative "refine"
require_relative "main"

Test.call
