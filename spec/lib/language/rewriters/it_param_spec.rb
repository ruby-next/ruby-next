# frozen_string_literal: true

require_relative "../../../spec_helper"

describe :it_param_rewriter do
  def process(source)
    RubyNext::Language.transform(
      source,
      rewriters: [RubyNext::Language::Rewriters::ItParam],
      using: false,
      context: RubyNext::Language::TransformContext.new
    )
  end

  ruby_version_is "3.4"..."" do
    it "rewrites code" do
      new_source = process(<<~RUBY)
        1.then {
          it.to_s
        }
      RUBY

      new_source.should == <<~RUBY
        1.then { |it|
          it.to_s
        }
      RUBY
    end

    it "treats an explicit `it` parameter as a fixed point" do
      new_source = process(<<~RUBY)
        1.then { |it|
          it.to_s
        }
      RUBY

      new_source.should == <<~RUBY
        1.then { |it|
          it.to_s
        }
      RUBY
    end
  end
end
