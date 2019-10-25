# frozen_string_literal: true

lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "ruby-next"

# override ruby_version_is method to always run tests
def ruby_version_is(*)
  yield
end
