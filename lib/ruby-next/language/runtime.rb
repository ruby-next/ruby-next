# frozen_string_literal: true

require "require-hooks/setup"

require "ruby-next"
require "ruby-next/language"
require "ruby-next/language/eval"

module RubyNext
  module Language
    runtime!

    # Module responsible for runtime transformations
    module Runtime
      using RubyNext

      class << self
        def load(path, contents)
          contents ||= File.read(path)
          new_contents = transform contents, path: path

          RubyNext.debug_source new_contents, path

          new_contents
        end

        def transform(contents, **options)
          Language.transform(contents, rewriters: Language.current_rewriters, **options)
        end
      end
    end
  end
end

RequireHooks.source_transform(
  patterns: RubyNext::Language.include_patterns,
  exclude_patterns: RubyNext::Language.exclude_patterns
) do |path, contents|
  RubyNext::Language::Runtime.load(path, contents)
end
