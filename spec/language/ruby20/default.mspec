# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

lib = File.expand_path("../../../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "backports/2.5"
require "ruby-next/core_ext"
RubyNext::Core.strategy = :backports

require "ruby-next/language/setup"
RubyNext::Language.setup_gem_load_path "ruby20"
