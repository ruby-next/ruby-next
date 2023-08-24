# frozen_string_literal: true

class AssignmentRewriter < RubyNext::Language::Rewriters::Text
  NAME = "assignment-operator"
  MIN_SUPPORTED_VERSION = Gem::Version.new(RubyNext::NEXT_VERSION)

  def safe_rewrite(source)
    source.gsub(":=") do |match|
      context.track! self

      "="
    end
  end
end

RubyNext::Language.rewriters << AssignmentRewriter
