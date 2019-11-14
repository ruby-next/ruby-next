# frozen_string_literal: true

require "ruby-next/language/runtime"
require "ruby-next/core/runtime"

RubyNext::Language::Runtime.watch_dirs << Dir.pwd

require "stringio"

# Hijack stderr to avoid printing exceptions while executing ruby files
stderr = StringIO.new

orig_stderr, $stderr = $stderr, stderr

at_exit do
  $stderr = orig_stderr

  if ($0 && File.exist?($0)) &&
      (NoMethodError === $! || SyntaxError === $!)
    load($0)
    exit!(0)
  end

  puts(stderr.tap(&:rewind).read)
end
