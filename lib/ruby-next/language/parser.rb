# frozen_string_literal: true

require "ruby-next/utils"

require "parser/ruby27"
RubyNext::Language::Parser = Parser::Ruby27

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

# See https://github.com/whitequark/parser/#usage
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index = true
