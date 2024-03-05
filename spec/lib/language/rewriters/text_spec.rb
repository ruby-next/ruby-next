# frozen_string_literal: true

require_relative "../../../spec_helper"

module RewritersSpecs
  class TextRewriter < RubyNext::Language::Rewriters::Text
    def safe_rewrite(source)
      return source if context.path&.end_with?(".go")

      source.gsub(":=", "=")
    end
  end

  class PacoRewriter < RubyNext::Language::Rewriters::Text
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
end

describe :text_rewriter, shared: true do
  it "rewrites code" do
    new_source = @rewriter.rewrite(<<~RUBY)
      a := "Hello, 世界"
      
      b:=42
    RUBY

    new_source.should == <<~RUBY
      a = "Hello, 世界"
      
      b=42
    RUBY
  end

  it "doesn't rewrite comments" do
    new_source = @rewriter.rewrite(<<~RUBY)
      # This is a comment := about assignment
      a := "Hello, 世界"
    RUBY

    new_source.should == <<~RUBY
      # This is a comment := about assignment
      a = "Hello, 世界"
    RUBY
  end

  it "doesn't rewrite string literals" do
    new_source = @rewriter.rewrite(<<~RUBY)
      a := "Hello, LANG := RUBY"
    RUBY

    new_source.should == <<~RUBY
      a = "Hello, LANG := RUBY"
    RUBY
  end

  it "supports interpolation" do
    new_source = @rewriter.rewrite(<<~'RUBY')
      a := "Hello, LANG := #{ x := %Q{RUBY := #{ a := 2 }} }"
    RUBY

    new_source.should == <<~'RUBY'
      a = "Hello, LANG := #{ x = %Q{RUBY := #{ a = 2 }} }"
    RUBY
  end

  it "does not interpolate non-interpolatable strings" do
    new_source = @rewriter.rewrite(<<~'RUBY')
      a := 'Hello, LANG := #{ x := "RUBY" }'
    RUBY

    new_source.should == <<~'RUBY'
      a = 'Hello, LANG := #{ x := "RUBY" }'
    RUBY
  end

  it "handles non-string literals" do
    new_source = @rewriter.rewrite(<<~RUBY)
      a := %i[foo bar]
      r := %r{x:=1}
    RUBY

    new_source.should == <<~RUBY
      a = %i[foo bar]
      r = %r{x:=1}
    RUBY
  end
end

describe "text rewriter" do
  before(:each) do
    @rewriter = RewritersSpecs::TextRewriter.new(RubyNext::Language::TransformContext.new)
  end

  it_behaves_like :text_rewriter, :rewrite

  it "has access to the source path via context" do
    RewritersSpecs::TextRewriter.transform("a := 1", path: "foo.rb").should == "a = 1" # rubocop:disable Lint/Void
    RewritersSpecs::TextRewriter.transform("a := 1", path: "foo.go").should == "a := 1"
  end
end

describe "paco rewriter" do
  before(:each) do
    @rewriter = RewritersSpecs::PacoRewriter.new(RubyNext::Language::TransformContext.new)
  end

  it_behaves_like :text_rewriter, :rewrite
end
