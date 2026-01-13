# frozen_string_literal: true

RubyNext::Core.patch String, name: "StringStripWithSelectors", method: :strip, version: "4.0", supported: String.instance_method(:strip).arity != 0, core_ext: :prepend do
  <<-RUBY
def strip(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  sub(/\\A[\#{pattern}]+/, "").tap { |str| str.sub!(/[\#{pattern}]+\\z/, "") }
end
  RUBY
end

RubyNext::Core.patch String, name: "StringStripBangWithSelectors", method: :strip!, version: "4.0", supported: String.instance_method(:strip!).arity != 0, core_ext: :prepend do
  <<-RUBY
def strip!(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  original = dup

  sub!(/\\A[\#{pattern}]+/, "")
  sub!(/[\#{pattern}]+\\z/, "")

  self == original ? nil : self
end
  RUBY
end

RubyNext::Core.patch String, name: "StringLstripWithSelectors", method: :lstrip, version: "4.0", supported: String.instance_method(:lstrip).arity != 0, core_ext: :prepend do
  <<-RUBY
def lstrip(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  sub(/\\A[\#{pattern}]+/, "")
end
  RUBY
end

RubyNext::Core.patch String, name: "StringLstripBangWithSelectors", method: :lstrip!, version: "4.0", supported: String.instance_method(:lstrip!).arity != 0, core_ext: :prepend do
  <<-RUBY
def lstrip!(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  sub!(/\\A[\#{pattern}]+/, "")
end
  RUBY
end

RubyNext::Core.patch String, name: "StringRstripWithSelectors", method: :rstrip, version: "4.0", supported: String.instance_method(:rstrip).arity != 0, core_ext: :prepend do
  <<-RUBY
def rstrip(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  sub(/[\#{pattern}]+\\z/, "")
end
  RUBY
end

RubyNext::Core.patch String, name: "StringRstripBangWithSelectors", method: :rstrip!, version: "4.0", supported: String.instance_method(:rstrip!).arity != 0, core_ext: :prepend do
  <<-RUBY
def rstrip!(*selectors)
  return super() if selectors.empty?

  pattern = RubyNext::Core::StringStripSelectors.build_pattern(selectors)
  return dup unless pattern

  sub!(/[\#{pattern}]+\\z/, "")
end
  RUBY
end

module RubyNext
  module Core
    module StringStripSelectors
      # Converts selector strings (like "0-9", "^a-z", "abc") into a regex character class pattern.
      # For multiple selectors, we need to handle intersection/negation
      def self.build_pattern(selectors)
        selectors.each { |selector| raise TypeError, "no implicit conversion of #{selector} into String" unless selector.respond_to?(:to_str) }

        if selectors.length == 1
          selector = selectors[0].to_str
          if selector.start_with?("^")
            char_class = escape_for_char_class(selector[1..-1])
            "[^#{char_class}]"
          elsif !selector.empty?
            char_class = escape_for_char_class(selector)
            "[#{char_class}]"
          end
        else
          positive = []
          negative = []

          selectors.each do |s|
            str = s.to_str
            if str.start_with?("^")
              negative << escape_for_char_class(str[1..-1])
            elsif !str.empty?
              positive << escape_for_char_class(str)
            end
          end

          if positive.any? && negative.any?
            pos_class = positive.join
            neg_class = negative.join
            "[#{pos_class}&&[^#{neg_class}]]"
          elsif positive.any?
            "[#{positive.join}]"
          elsif negative.any?
            "[^#{negative.join}]"
          end
        end
      end

      def self.escape_for_char_class(selector)
        str = selector.to_str

        # Escape special characters but preserve ranges
        # Inside character class: need to escape ] \ ^
        # - is special only between characters (part of range)
        str.gsub(/(?<!^)([\]\\\^])/) { "\\#{$1}" }
      end
    end
  end
end
