# frozen_string_literal: true

# Load experimental, proposed etc. Ruby features

require "ruby-next/language/rewriters/method_reference"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::MethodReference

require "ruby-next/language/rewriters/shorthand_hash"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::ShorthandHash
