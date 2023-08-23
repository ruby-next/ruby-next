#!/usr/bin/env ruby
# frozen_string_literal: true

require "ruby-next/language/runtime"

RubyNext::Language.include_patterns << File.join(__dir__, "*.rb")

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__))
loader.setup

p Beach.call(:k, 304) #=> :scientifically_favorable
