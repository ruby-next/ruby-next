# frozen_string_literal: true

require "pathname"

require "ruby-next"
require "ruby-next/utils"
require "ruby-next/language"
require "ruby-next/language/eval"

module RubyNext
  module Language
    runtime!

    # Module responsible for runtime transformations
    module Runtime
      using RubyNext

      class << self
        include Utils

        def load(path, wrap: false)
          raise "RubyNext cannot handle `load(smth, wrap: true)`" if wrap

          contents = File.read(path)
          new_contents = transform contents

          RubyNext.debug_source new_contents, path

          evaluate(new_contents, path)
          true
        end

        def transform(contents, **options)
          Language.transform(contents, rewriters: Language.current_rewriters, **options)
        end

        def feature_path(path, implitic_ext: true)
          path = resolve_feature_path(path, implitic_ext: implitic_ext)
          return if path.nil?
          return if File.extname(path) != ".rb" && implitic_ext
          return unless Language.transformable?(path)
          path
        end

        # Based on https://github.com/ruby/ruby/blob/b588fd552390c55809719100d803c36bc7430f2f/load.c#L403-L415
        def feature_loaded?(feature)
          return true if $LOADED_FEATURES.include?(feature)

          feature = Pathname.new(feature).cleanpath.to_s

          # Check absoulute and relative paths
          return true if $LOADED_FEATURES.include?(File.expand_path(feature))

          candidates = []

          $LOADED_FEATURES.each do |lf|
            candidates << lf if lf.end_with?("/#{feature}")
          end

          return false if candidates.empty?

          $LOAD_PATH.each do |lp|
            return true if candidates.include?(File.join(lp, feature))
          end

          false
        end

        if defined?(JRUBY_VERSION) || defined?(TruffleRuby)
          def evaluate(code, filepath)
            new_toplevel.eval(code, filepath)
          end

          def new_toplevel
            # Create new "toplevel" binding to avoid lexical scope re-use
            # (aka "leaking refinements")
            eval "proc{binding}.call", TOPLEVEL_BINDING, __FILE__, __LINE__
          end
        else
          def evaluate(code, filepath)
            # This is workaround to solve the "leaking refinements" problem in MRI
            RubyVM::InstructionSequence.compile(code, filepath).then do |iseq|
              iseq.eval
            end
          end
        end
      end
    end
  end
end

# Patch Kernel to hijack require/require_relative/load/eval
module Kernel
  module_function

  alias_method :require_without_ruby_next, :require
  def require(path)
    path = path.to_path if path.respond_to?(:to_path)
    raise TypeError unless path.respond_to?(:to_str)

    path = path.to_str

    raise TypeError unless path.is_a?(::String)

    # if extname == ".rb" => lookup feature -> resolve feature -> load
    # if extname != ".rb" => append ".rb" - lookup feature -> resolve feature -> lookup orig (no ext) -> resolve orig (no ext) -> load

    if File.extname(path) != ".rb"
      return false if RubyNext::Language::Runtime.feature_loaded?(path + ".rb")

      realpath = RubyNext::Language::Runtime.feature_path(path + ".rb")

      if realpath
        $LOADED_FEATURES << realpath
        RubyNext::Language::Runtime.load(realpath)
        return true
      end
    end

    return false if RubyNext::Language::Runtime.feature_loaded?(path)

    realpath = RubyNext::Language::Runtime.feature_path(path)
    return require_without_ruby_next(path) unless realpath

    $LOADED_FEATURES << realpath

    RubyNext::Language::Runtime.load(realpath)

    true
  rescue => e
    $LOADED_FEATURES.delete realpath
    RubyNext.warn "RubyNext failed to require '#{path}': #{e.message}"
    require_without_ruby_next(path)
  end

  alias_method :require_relative_without_ruby_next, :require_relative
  def require_relative(path)
    path = path.to_path if path.respond_to?(:to_path)
    raise TypeError unless path.respond_to?(:to_str)
    path = path.to_str

    raise TypeError unless path.is_a?(::String)

    return require(path) if Pathname.new(path).absolute?

    loc = caller_locations(1..1).first
    from = loc.absolute_path || loc.path || File.join(Dir.pwd, "main")
    realpath = File.absolute_path(
      File.join(
        File.dirname(File.absolute_path(from)),
        path
      )
    )

    require(realpath)
  end

  alias_method :load_without_ruby_next, :load
  def load(path, wrap = false)
    path = path.to_path if path.respond_to?(:to_path)
    raise TypeError unless path.respond_to?(:to_str)

    path = path.to_str

    raise TypeError unless path.is_a?(::String)

    realpath =
      if path =~ /^\.\.?\//
        path
      else
        RubyNext::Language::Runtime.feature_path(path, implitic_ext: false)
      end

    return load_without_ruby_next(path, wrap) unless realpath

    RubyNext::Language::Runtime.load(realpath, wrap: wrap)
  rescue => e
    RubyNext.warn "RubyNext failed to load '#{path}': #{e.message}"
    load_without_ruby_next(path)
  end
end
