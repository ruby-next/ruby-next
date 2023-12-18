# frozen_string_literal: true

# Load edge Ruby features

require "ruby-next/language/rewriters/edge/it_param"

# We must add this rewriter before nubmered params rewriter to allow it to transform the source code further

number_params = RubyNext::Language.rewriters.index(RubyNext::Language::Rewriters::NumberedParams)

if number_params
  RubyNext::Language.rewriters.insert(number_params, RubyNext::Language::Rewriters::ItParam)
else
  RubyNext::Language.rewriters << RubyNext::Language::Rewriters::ItParam
end
