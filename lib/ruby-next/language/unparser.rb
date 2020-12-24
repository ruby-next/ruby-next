# frozen_string_literal: true

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

require "unparser"

# PR: https://github.com/mbj/unparser/pull/230
if defined? Unparser::Emitter::InPattern
  Unparser::Emitter::InPattern.prepend(Module.new do
    def dispatch
      super
      nl unless branch
    end
  end)
end
