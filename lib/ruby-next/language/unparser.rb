# frozen_string_literal: true

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

require "unparser"
