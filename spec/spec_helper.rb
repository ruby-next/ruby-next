# frozen_string_literal: true

# suppress "warning: <feature> is experimental, and the behavior may change in future versions of Ruby!"
$VERBOSE = nil

# override ruby_version_is method to always run tests
def ruby_version_is(*)
  yield
end
