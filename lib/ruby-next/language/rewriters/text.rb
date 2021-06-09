# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class Text < Abstract
        def self.text?
          true
        end

        def rewrite(source)
          source
        end
      end
    end
  end
end
