# frozen_string_literal: true

# This file contains patches to RuboCop to support
# edge features and fix some bugs with 2.7+ syntax

module RuboCop
  module AST
    module Traversal
      # Fixed in https://github.com/rubocop-hq/rubocop/pull/7786
      unless defined?(::RuboCop::AST::CaseMatchNode)
        %i[case_match in_pattern].each do |type|
          module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def on_#{type}(node)
              node.children.each { |child| send(:"on_\#{child.type}", child) if child }
              nil
            end
          RUBY
        end
      end
    end
  end
end

module RuboCop
  module Cop
    # Commissioner class is responsible for processing the AST and delegating
    # work to the specified cops.
    class Commissioner
      def on_meth_ref(node)
        trigger_responding_cops(:on_meth_ref, node)
      end

      unless method_defined?(:on_numblock)
        def on_numblock(node)
          children = node.children
          child = children[0]
          send(:"on_#{child.type}", child)
          # children[1] is the number of parameters
          return unless (child = children[2])

          send(:"on_#{child.type}", child)
        end
      end
    end
  end
end
