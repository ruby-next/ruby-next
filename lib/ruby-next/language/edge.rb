# frozen_string_literal: true

# Load edge Ruby features

require "ruby-next/language/rewriters/endless_method"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::EndlessMethod

require "ruby-next/language/rewriters/right_hand_assignment"
RubyNext::Language.rewriters << RubyNext::Language::Rewriters::RightHandAssignment
