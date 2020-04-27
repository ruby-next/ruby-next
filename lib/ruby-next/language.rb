# frozen_string_literal: true

gem "ruby-next-parser", ">= 2.8.0.3"
gem "unparser", ">= 0.4.7"

require "set"

require "ruby-next"

module RubyNext
  # Language module contains tools to transpile newer Ruby syntax
  # into an older one.
  #
  # It works the following way:
  #   - Takes a Ruby source code as input
  #   - Generates the AST using the edge parser (via the `parser` gem)
  #   - Pass this AST through the list of processors (one feature = one processor)
  #   - Each processor may modify the AST
  #   - Generates a transpiled source code from the transformed AST (via the `unparser` gem)
  module Language
    using RubyNext

    require "ruby-next/language/parser"
    require "ruby-next/language/unparser"

    class TransformContext
      attr_reader :versions, :use_ruby_next

      def initialize
        # Minimum supported RubyNext version
        @min_version = MIN_SUPPORTED_VERSION
        @dirty = false
        @versions = Set.new
        @use_ruby_next = false
      end

      # Called by rewriter when it performs transfomrations
      def track!(rewriter)
        @dirty = true
        versions << rewriter.class::MIN_SUPPORTED_VERSION
      end

      def use_ruby_next!
        @use_ruby_next = true
      end

      alias use_ruby_next? use_ruby_next

      def dirty?
        @dirty == true
      end

      def min_version
        versions.min
      end

      def sorted_versions
        versions.to_a.sort
      end
    end

    class << self
      attr_accessor :rewriters
      attr_reader :watch_dirs

      attr_accessor :strategy

      MODES = %i[rewrite ast].freeze

      attr_reader :mode

      def mode=(val)
        raise ArgumentError, "Unknown mode: #{val}. Available: #{MODES.join(",")}" unless MODES.include?(val)
        @mode = val
      end

      def rewrite?
        mode == :rewrite?
      end

      def ast?
        mode == :ast
      end

      def runtime!
        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0") && !defined?(Unparser::Emitter::CaseMatch)
          RubyNext.warn "Ruby Next fallbacks to \"rewrite\" transpiling mode since Unparser doesn't support 2.7 AST yet.\n" \
            "See https://github.com/mbj/unparser/pull/142"
          self.mode = :rewrite
        end

        @runtime = true
      end

      def runtime?
        @runtime
      end

      def transform(*args, **kwargs)
        if mode == :rewrite
          rewrite(*args, **kwargs)
        else
          regenerate(*args, **kwargs)
        end
      end

      def regenerate(source, rewriters: self.rewriters, using: RubyNext::Core.refine?, context: TransformContext.new)
        parse_with_comments(source).then do |(ast, comments)|
          rewriters.inject(ast) do |tree, rewriter|
            rewriter.new(context).process(tree)
          end.then do |new_ast|
            next source unless context.dirty?

            Unparser.unparse(new_ast, comments)
          end.then do |source|
            next source unless RubyNext::Core.refine?
            next source unless using && context.use_ruby_next?

            Core.inject! source.dup
          end
        end
      end

      def rewrite(source, rewriters: self.rewriters, using: RubyNext::Core.refine?, context: TransformContext.new)
        rewriters.inject(source) do |src, rewriter|
          buffer = Parser::Source::Buffer.new("<dynamic>")
          buffer.source = src

          rewriter.new(context).rewrite(buffer, parse(src))
        end.then do |new_source|
          next source unless context.dirty?
          new_source
        end.then do |source|
          next source unless RubyNext::Core.refine?
          next source unless using && context.use_ruby_next?

          Core.inject! source.dup
        end
      end

      def transformable?(path)
        watch_dirs.any? { |dir| path.start_with?(dir) }
      end

      # Rewriters required for the current version
      def current_rewriters
        @current_rewriters ||= rewriters.select(&:unsupported_syntax?)
      end

      private

      attr_writer :watch_dirs
    end

    self.rewriters = []
    self.watch_dirs = %w[app lib spec test].map { |path| File.join(Dir.pwd, path) }
    self.mode = ENV.fetch("RUBY_NEXT_TRANSPILE_MODE", "ast").to_sym

    require "ruby-next/language/rewriters/base"

    require "ruby-next/language/rewriters/args_forward"
    rewriters << Rewriters::ArgsForward

    require "ruby-next/language/rewriters/numbered_params"
    rewriters << Rewriters::NumberedParams

    require "ruby-next/language/rewriters/pattern_matching"
    rewriters << Rewriters::PatternMatching

    # Put endless range in the end, 'cause Parser fails to parse it in
    # pattern matching
    require "ruby-next/language/rewriters/endless_range"
    rewriters << Rewriters::EndlessRange

    if ENV["RUBY_NEXT_EDGE"] == "1"
      require "ruby-next/language/edge"
    end

    if ENV["RUBY_NEXT_PROPOSED"] == "1"
      require "ruby-next/language/proposed"
    end
  end
end
