# frozen_string_literal: true

class AssignmentRewriter < RubyNext::Language::Rewriters::Text
  parser do
    def default
      many(
        alt(
          c_assignment,
          any_char
        )
      )
    end

    def c_assignment
      string(":=").fmap { track! }.fmap { "=" }
    end
  end

  def safe_rewrite(source)
    parse(source).join
  end
end

RubyNext::Language.rewriters << AssignmentRewriter
