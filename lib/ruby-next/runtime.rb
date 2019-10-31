# frozen_string_literal: true

require "pathname"

require "ruby-next"
require "ruby-next/utils"
require "ruby-next/language"

module RubyNext
  # Module responsible for runtime transformations
  module Runtime
    class << self
      include Utils

      attr_reader :load_dirs

      def load(path, wrap: false)
        contents = File.read(path)
        # inject `using RubyNext`
        contents.sub!(/^(\s*[^#\s].*)/, 'using RubyNext;\1')
        # perform syntax transformations
        new_contents = Language.transform(contents)
        raise "RubyNext cannot handle `load(smth, wrap: true)`" if wrap
        TOPLEVEL_BINDING.eval(new_contents, path)
        true
      end

      def transformable?(path)
        load_dirs.any? { |dir| path.start_with?(dir) }
      end

      def feature_path(path)
        path = resolve_feature_path(path)
        return if File.extname(path) != ".rb"
        return unless transformable?(path)
        path
      end

      private

      attr_writer :load_dirs
    end

    self.load_dirs = %w[app lib spec test].map { |path| File.join(Dir.pwd, path) }
    load_dirs << Dir.pwd
  end
end

# Patch Kernel to hijack require/require_relative/load
module Kernel
  module_function # rubocop:disable Style/ModuleFunction

  alias_method :require_without_ruby_next, :require
  def require(path)
    realpath = RubyNext::Runtime.feature_path(path)
    return require_without_ruby_next(path) unless realpath

    return false if $LOADED_FEATURES.include?(realpath)

    RubyNext::Runtime.load(realpath)

    $LOADED_FEATURES << realpath
    true
  rescue => e
    warn "RubyNext failed to require '#{path}': #{e.message}"
    require_without_ruby_next(path)
  end

  alias_method :require_relative_without_ruby_next, :require_relative
  def require_relative(path)
    from = caller_locations(1..1).first.absolute_path
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
    realpath = RubyNext::Runtime.feature_path(path)

    return load_without_ruby_next(path, wrap) unless realpath

    RubyNext::Runtime.load(realpath, wrap: wrap)
  rescue => e
    warn "RubyNext failed to load '#{path}': #{e.message}"
    load_without_ruby_next(path)
  end
end
