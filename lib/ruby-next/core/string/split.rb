# frozen_string_literal: true

RubyNext::Core.patch String,
  name: "StringSplit",
  version: "2.6",
  supported: "a b".split(" ", &proc {}) == "a b",
  location: [__FILE__, __LINE__ + 3],
  core_ext: :prepend do
  <<~RUBY
    def split(*args, &block)
      return super unless block_given?
      super.each { |el| yield el }
      self
    end
  RUBY
end
