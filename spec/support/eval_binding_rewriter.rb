# frozen_string_literal: true

# Add binding argument to all self-less eval's
module RubyNext
  class EvalBindingRewriter < Language::Rewriters::Base
    NAME = "eval-binding"
    SYNTAX_PROBE = "I < am > broken"
    MIN_SUPPORTED_VERSION = Gem::Version.new("10.0.0")

    def on_send(node)
      receiver, mid, *children = *node

      return super(node) unless mid == :eval && receiver.nil? && children.size == 1

      context.track!(self)

      node.updated(
        nil,
        [
          receiver,
          mid,
          *children,
          s(:send, nil, :binding)
        ]
      ).tap do |new_node|
        replace(node.loc.expression, new_node)

        # Heredocs are evil 😼
        next unless node.children.last.loc.respond_to?(:heredoc_body)

        # Cleanup heredoc body
        loc = node.children.last.loc.heredoc_body.join(node.children.last.loc.heredoc_end)
        padding = "\n" * (loc.last_line - loc.first_line)

        replace(loc, padding)
      end
    end
  end
end

RubyNext::Language.rewriters << RubyNext::EvalBindingRewriter
