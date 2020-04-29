# frozen_string_literal: true

# This file contains patches to RuboCop to support
# edge features and fix some bugs with 2.7+ syntax

require "parser/ruby-next/version"

module RuboCop
  # Transform Ruby Next parser version to a float, e.g.: "2.8.0.1" => 2.801
  RUBY_NEXT_VERSION = Parser::NEXT_VERSION.match(/(^\d+)\.(.+)$/)[1..-1].map { |part| part.delete(".") }.join(".").to_f

  class TargetRuby
    class RuboCopNextConfig < RuboCopConfig
      private

      def find_version
        version = @config.for_all_cops["TargetRubyVersion"]
        return unless version == "next"

        RUBY_NEXT_VERSION
      end
    end

    new_rubies = KNOWN_RUBIES + [RUBY_NEXT_VERSION]
    remove_const :KNOWN_RUBIES
    const_set :KNOWN_RUBIES, new_rubies

    new_sources = [RuboCopNextConfig] + SOURCES
    remove_const :SOURCES
    const_set :SOURCES, new_sources
  end
end

module RuboCop
  class ProcessedSource
    module ParserClassExt
      def parser_class(version)
        return super unless version == RUBY_NEXT_VERSION

        require "parser/rubynext"
        Parser::RubyNext
      end
    end

    prepend ParserClassExt
  end
end

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

      unless method_defined?(:on_def_e)
        def on_def_e(node)
          _name, _args_node, body_node = *node
          send(:"on_#{body_node.type}", body_node)
        end

        def on_defs_e(node)
          _definee_node, _name, _args_node, body_node = *node
          send(:"on_#{body_node.type}", body_node)
        end
      end

      unless method_defined?(:on_rasgn)
        def on_rasgn(node)
          val_node, asgn_node = *node
          send(:"on_#{asgn_node.type}", asgn_node)
          send(:"on_#{val_node.type}", val_node)
        end

        def on_mrasgn(node)
          lhs, rhs = *node
          send(:"on_#{lhs.type}", lhs)
          send(:"on_#{rhs.type}", rhs)
        end
      end
    end
  end
end
