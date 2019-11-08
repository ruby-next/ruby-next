# frozen_string_literal: true

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

require "unparser"

# Unparser patches

# Unparser doesn't support endless ranges
# Source: https://github.com/mbj/unparser/blob/a4f959d58b660ef0630659efa5882fc20936eb18/lib/unparser/emitter/literal/range.rb
# TODO: propose a PR
class Unparser::Emitter::Literal::Range
  private

  def dispatch
    visit(begin_node)
    write(TOKENS.fetch(node.type))
    visit(end_node) unless end_node.nil?
  end
end
