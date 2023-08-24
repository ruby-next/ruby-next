# frozen_string_literal: true

require "date"

class NoteDateRewriter < RubyNext::Language::Rewriters::Text
  NAME = "note-comment-date"
  MIN_SUPPORTED_VERSION = Gem::Version.new(RubyNext::NEXT_VERSION)

  def rewrite(source)
    source.gsub("# NOTE:") do |match|
      context.track! self

      "# NOTE (#{Date.today}):"
    end
  end
end

RubyNext::Language.rewriters << NoteDateRewriter
