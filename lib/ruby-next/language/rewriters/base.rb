# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class Base < ::Parser::TreeRewriter
        class << self
          # Returns true if the syntax is supported
          # by the current Ruby (performs syntax check, not version check)
          def unsupported_syntax?
            save_verbose, $VERBOSE = $VERBOSE, nil
            eval_mid = Kernel.respond_to?(:eval_without_ruby_next) ? :eval_without_ruby_next : :eval
            Kernel.send eval_mid, self::SYNTAX_PROBE
            false
          rescue SyntaxError, NameError
            true
          ensure
            $VERBOSE = save_verbose
          end

          # Returns true if the syntax is supported
          # by the specified version
          def unsupported_version?(version)
            self::MIN_SUPPORTED_VERSION > version
          end
        end

        def initialize(context)
          @context = context
          super()
        end

        def s(type, *children)
          ::Parser::AST::Node.new(type, children)
        end

        private

        attr_reader :context
      end
    end
  end
end
