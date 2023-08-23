# frozen_string_literal: true

require_relative "../../../spec_helper"

module RewritersSpecs
  class TextRewriter < RubyNext::Language::Rewriters::Text
    def safe_rewrite(source)
      source.gsub(":=", "=")
    end
  end
end

describe "Text rewriters" do
  before(:each) do
    @rewriter = RewritersSpecs::TextRewriter.new(RubyNext::Language::TransformContext.new)
  end

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
end
