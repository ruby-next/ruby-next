# frozen_string_literal: true

# Add binding argument to all self-less eval's
module RubyNext
  class EvalBindingRewriter < Language::Rewriters::Base
    NAME = "eval-binding"
    SYNTAX_PROBE = "I < am > broken"
    MIN_SUPPORTED_VERSION = Gem::Version.new("10.0.0")

    def on_send(node)
      receiver, mid, *children = *node

      return super unless mid == :eval && receiver.nil? && children.size == 1

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
        # Heredocs are evil 😼
        if node.children.last.loc.respond_to?(:heredoc_body)
          replace(node.loc.expression, node.loc.expression.source.sub(/(\)?$)/, ', binding\1'))
        else
          replace(node.loc.expression, new_node)
        end
      end
    end
  end
end

RubyNext::Language.rewriters << RubyNext::EvalBindingRewriter
