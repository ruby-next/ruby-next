# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

begin
  require "pry-byebug"
rescue LoadError
  nil
end

require "ruby-next/language"
# It's important to enable optional rewriters before loading Runtime module,
# 'cause it creates a copy of the original list
require "ruby-next/language/rewriters/method_reference"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::MethodReference

require "ruby-next/language/runtime"
require "ruby-next/core/runtime"
