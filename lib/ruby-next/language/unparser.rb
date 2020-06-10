# frozen_string_literal: true

# Require current parser without warnings
save_verbose, $VERBOSE = $VERBOSE, nil
require "parser/current"
$VERBOSE = save_verbose

require "unparser"

unless defined?(Unparser::UnknownEmitterError)
  module Unparser
    class UnknownEmitterError < ArgumentError
    end

    Emitter.singleton_class.prepend(Module.new do
      def emitter(node, parent)
        raise UnknownEmitterError, "No emitter for node: #{node.type.inspect}" unless Emitter::REGISTRY.key?(node.type)
        super
      end
    end)
  end
end
