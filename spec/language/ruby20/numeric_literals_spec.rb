# Use require to load via LOAD_PATH (to use transpiled files if required)
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

require "shared/numeric_literals"
