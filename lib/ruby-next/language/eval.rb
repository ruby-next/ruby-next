# frozen_string_literal: true

module RubyNext
  module Language
    module KernelEval
      refine Kernel do
        def eval(source, bind = nil, *args)
          new_source = ::RubyNext::Language::Runtime.transform(
            source,
            using: bind&.receiver == TOPLEVEL_BINDING.receiver || bind&.receiver&.is_a?(Module)
          )
          $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
          super new_source, bind, *args
        end
      end
    end

    module InstanceEval # :nodoc:
      refine Object do
        def instance_eval(*args, &block)
          return super(*args, &block) if block_given?

          source = args.shift
          new_source = ::RubyNext::Language::Runtime.transform(source, using: false)
          $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
          super new_source, *args
        end
      end
    end

    module ClassEval
      refine Module do
        def module_eval(*args, &block)
          return super(*args, &block) if block_given?

          source = args.shift
          new_source = ::RubyNext::Language::Runtime.transform(source, using: false)
          $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
          super new_source, *args
        end

        def class_eval(*args, &block)
          return super(*args, &block) if block_given?

          source = args.shift
          new_source = ::RubyNext::Language::Runtime.transform(source, using: false)
          $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
          super new_source, *args
        end
      end
    end

    # Refinements for `eval`-like methods.
    # Transpiling eval is only possible if we do not use local from the binding,
    # because we cannot access the binding of caller (without non-production ready hacks).
    #
    # This module is meant mainly for testing purposes.
    module Eval
      include InstanceEval
      include ClassEval
      include KernelEval
    end
  end
end
