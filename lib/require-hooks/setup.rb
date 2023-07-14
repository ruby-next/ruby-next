# frozen_string_literal: true

require "require-hooks/api"

mode = ENV["REQUIRE_HOOKS_MODE"]

case mode
when "patch"
  require "require-hooks/mode/kernel_patch"
when "load_iseq"
  require "require-hooks/mode/load_iseq"
else
  if defined?(::RubyVM::InstructionSequence)
    require "require-hooks/mode/load_iseq"
  else
    require "require-hooks/mode/kernel_patch"
  end
end
