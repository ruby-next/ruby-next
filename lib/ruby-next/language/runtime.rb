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
          return unless Language.transformable?(path)

          contents ||= File.read(path)
          new_contents = transform contents

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

RequireHooks.source_transform do |path, contents|
  RubyNext::Language::Runtime.load(path, contents)
end
