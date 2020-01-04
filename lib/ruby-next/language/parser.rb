# frozen_string_literal: true

require "ruby-next/utils"

require "parser/ruby27"
RubyNext::Language::Parser = Parser::Ruby27

# See https://github.com/whitequark/parser/#usage
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_arg_inside_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index = true
