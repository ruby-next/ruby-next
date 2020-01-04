# frozen_string_literal: true

require "pathname"

require "ruby-next"
require "ruby-next/utils"
require "ruby-next/language"

using RubyNext

module RubyNext
  module Language
    # Module responsible for runtime transformations
    module Runtime
      # Apply only rewriters required for the current version
      REWRITERS = RubyNext::Language.rewriters.select(&:unsupported_syntax?)

      class << self
        include Utils

        attr_reader :watch_dirs

        def load(path, wrap: false)
          raise "RubyNext cannot handle `load(smth, wrap: true)`" if wrap

          contents = File.read(path)
          new_contents = transform contents

          $stdout.puts source_with_lines(new_contents, path) if ENV["RUBY_NEXT_DEBUG"] == "1"

          TOPLEVEL_BINDING.eval(new_contents, path)
          true
        end

        def transform(contents, **options)
          Language.transform(contents, rewriters: REWRITERS, **options)
        end

        def transformable?(path)
          watch_dirs.any? { |dir| path.start_with?(dir) }
        end

        def feature_path(path)
          path = resolve_feature_path(path)
          return if path.nil?
          return if File.extname(path) != ".rb"
          return unless transformable?(path)
          path
        end

        private

        attr_writer :watch_dirs
      end

      self.watch_dirs = %w[app lib spec test].map { |path| File.join(Dir.pwd, path) }
    end
  end
end

# Patch Kernel to hijack require/require_relative/load/eval
module Kernel
  module_function # rubocop:disable Style/ModuleFunction

  alias_method :require_without_ruby_next, :require
  def require(path)
    realpath = RubyNext::Language::Runtime.feature_path(path)
    return require_without_ruby_next(path) unless realpath

    return false if $LOADED_FEATURES.include?(realpath)

    RubyNext::Language::Runtime.load(realpath)

    $LOADED_FEATURES << realpath
    true
  rescue => e
    warn "RubyNext failed to require '#{path}': #{e.message}"
    require_without_ruby_next(path)
  end

  alias_method :require_relative_without_ruby_next, :require_relative
  def require_relative(path)
    from = caller_locations(1..1).first.absolute_path || File.join(Dir.pwd, "main")
    realpath = File.absolute_path(
      File.join(
        File.dirname(File.absolute_path(from)),
        path
      )
    )
    require(realpath)
  rescue => e
    warn "RubyNext failed to require relative '#{path}' from #{from}: #{e.message}"
    require_relative_without_ruby_next(path)
  end

  alias_method :load_without_ruby_next, :load
  def load(path, wrap = false)
    realpath = RubyNext::Language::Runtime.feature_path(path)

    return load_without_ruby_next(path, wrap) unless realpath

    RubyNext::Language::Runtime.load(realpath, wrap: wrap)
  rescue => e
    warn "RubyNext failed to load '#{path}': #{e.message}"
    load_without_ruby_next(path)
  end

  alias_method :eval_without_ruby_next, :eval
  def eval(source, bind = nil, *args)
    new_source = ::RubyNext::Language::Runtime.transform(source, eval: bind.nil?)
    $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
    eval_without_ruby_next new_source, bind, *args
  end
end

# Patch Object to hijack instance_eval
class Object
  alias_method :instance_eval_without_ruby_next, :instance_eval

  def instance_eval(*args, &block)
    return instance_eval_without_ruby_next(*args, &block) if block_given?

    source = args.shift
    new_source = ::RubyNext::Language::Runtime.transform(source, eval: true)
    $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
    instance_eval_without_ruby_next new_source, *args
  end
end

# Patch Module to hijack class_eval/module_eval
class Module
  alias_method :module_eval_without_ruby_next, :module_eval

  def module_eval(*args, &block)
    return module_eval_without_ruby_next(*args, &block) if block_given?

    source = args.shift
    new_source = ::RubyNext::Language::Runtime.transform(source, eval: true)
    $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
    module_eval_without_ruby_next new_source, *args
  end

  alias_method :class_eval_without_ruby_next, :class_eval

  def class_eval(*args, &block)
    return class_eval_without_ruby_next(*args, &block) if block_given?

    source = args.shift
    new_source = ::RubyNext::Language::Runtime.transform(source, eval: true)
    $stdout.puts ::RubyNext::Utils.source_with_lines(new_source, "(#{caller_locations(1, 1).first})") if ENV["RUBY_NEXT_DEBUG"] == "1"
    class_eval_without_ruby_next new_source, *args
  end
end
