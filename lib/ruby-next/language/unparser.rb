# frozen_string_literal: true

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

# For backward compatibility with older Unparser for EOL Rubies
if !Parser::Lexer.const_defined?(:ESCAPES)
  Parser::Lexer::ESCAPES = Parser::LexerStrings::ESCAPES
end

require "unparser"

# For backward compatibility with older Unparser
if RubyNext::Language::Builder.respond_to?(:emit_kwargs=) && !defined?(Unparser::Emitter::Kwargs)
  RubyNext::Language::Builder.emit_kwargs = false
end
