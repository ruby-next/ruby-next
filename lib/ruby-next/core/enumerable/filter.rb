# frozen_string_literal: true

RubyNext::Core.patch Enumerable,
  name: "EnumerableFilter",
  version: "2.6",
  supported: [].respond_to?(:filter) do
  <<~RUBY
    alias filter select
  RUBY
end

# Refine Array seprately, 'cause refining modules is vulnerable to prepend:
# - https://bugs.ruby-lang.org/issues/13446
#
# Also, Array also have `filter!`
RubyNext::Core.patch Array,
  refineable: Array,
  name: "ArrayFilter",
  version: "2.6",
  supported: [].respond_to?(:filter!) do
  <<~RUBY
    alias filter select
    alias filter! select!
  RUBY
end

RubyNext::Core.patch Hash,
  refineable: Hash,
  name: "HashFilter",
  version: "2.6",
  supported: {}.respond_to?(:filter!) do
  <<~RUBY
    alias filter select
    alias filter! select!
  RUBY
end
