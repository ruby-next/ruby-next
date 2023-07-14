# frozen_string_literal: true

require "bootsnap"
Bootsnap.setup(
  cache_dir: File.join(__dir__, "tmp/cache"),
  development_mode: true,
  load_path_cache: true,
  compile_cache_iseq: true,
  compile_cache_yaml: true
)

require "require-hooks/setup"

Bootsnap.instrumentation = ->(event, path) {
  puts "#{event}: #{File.basename(path)}"
}

RequireHooks.source_transform do |path, source|
  next unless path =~ /fixtures\/hello\.rb$/

  source ||= File.read(path)
  source.gsub!("Hello", "Good-bye")
  source
end

load File.join(__dir__, "hello.rb")

RequireHooks.around_load do |path, &block|
  next unless path =~ /fixtures\/hello\.rb$/

  was_frozen_string_literal = RubyVM::InstructionSequence.compile_option[:frozen_string_literal]
  begin
    RubyVM::InstructionSequence.compile_option = {frozen_string_literal: true}
    block.call
  ensure
    RubyVM::InstructionSequence.compile_option = {frozen_string_literal: was_frozen_string_literal}
  end
end

load File.join(__dir__, "hello.rb")
