# frozen_string_literal: true

require "ruby-next/language/runtime"
RubyNext::Language.include_patterns << File.join(__dir__, ".rb")

require_relative "refine"
require_relative "main"

Test.call
