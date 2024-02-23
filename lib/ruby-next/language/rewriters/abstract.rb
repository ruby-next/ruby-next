# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class Abstract < ::Parser::TreeRewriter
        NAME = "custom-rewriter"
        SYNTAX_PROBE = "1 = [}"
        MIN_SUPPORTED_VERSION = Gem::Version.new(RubyNext::NEXT_VERSION)

        class << self
          # Returns true if the syntax is not supported
          # by the current Ruby (performs syntax check, not version check)
          def unsupported_syntax?
            save_verbose, $VERBOSE = $VERBOSE, nil
            eval_mid = Kernel.respond_to?(:eval_without_ruby_next) ? :eval_without_ruby_next : :eval
            Kernel.send eval_mid, self::SYNTAX_PROBE, nil, __FILE__, __LINE__
            false
          rescue SyntaxError, StandardError
            true
          ensure
            $VERBOSE = save_verbose
          end

          # Returns true if the syntax is supported
          # by the specified version
          def unsupported_version?(version)
            version < self::MIN_SUPPORTED_VERSION
          end

          def text?
            false
          end

          def ast?
            false
          end

          def transform(source, **opts)
            Language.transform(source, rewriters: [self], using: false, **opts)
          end
        end

        def initialize(context)
          @context = context
          super()
        end

        private

        attr_reader :context
      end
    end
  end
end
