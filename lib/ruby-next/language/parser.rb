# frozen_string_literal: true

require "ruby-next/utils"

require "parser/ruby27"
RubyNext::Language::Parser = Parser::Ruby27

# See https://github.com/whitequark/parser/#usage
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index = true

Parser::Builders::Default.prepend(Module.new do
  def match_hash_var_from_str(begin_t, strings, end_t)
    super.tap do
      string = strings[0]
      next unless string.type == :str
      name, = *string
      @parser.static_env.declare(name)
    end
  end
end)
