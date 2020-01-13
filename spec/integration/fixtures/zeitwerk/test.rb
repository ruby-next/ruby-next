#!/usr/bin/env ruby

require "ruby-next/language/runtime"

RubyNext::Language.watch_dirs << __dir__

require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__))
loader.setup

p Beach.(:k, 304) #=> :scientifically_favorable
