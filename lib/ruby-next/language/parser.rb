# frozen_string_literal: true

require "ruby-next/utils"

# Prevent from loading current parser
$LOADED_FEATURES << RubyNext::Utils.resolve_feature_path("parser/current")
require "parser/current"

require "parser/ruby27"
RubyNext::Language::Parser = Parser::Ruby27

# See https://github.com/whitequark/parser/#usage
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index = true
