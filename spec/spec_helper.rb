# frozen_string_literal: true

# override ruby_version_is method to always run tests
def ruby_version_is(*)
  yield
end
