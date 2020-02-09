# frozen_string_literal: true

unless [].respond_to?(:filter)
  RubyNext::Core.patch Enumerable, name: "EnumerableFilter" do
    alias filter select
  end

  # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
  # - https://bugs.ruby-lang.org/issues/13446
  #
  # Also, Array also have `filter!`
  RubyNext::Core.patch Array, name: "ArrayFilter" do
    alias filter select
    alias filter! select!
  end

  RubyNext::Core.patch Hash, name: "HashFilter" do
    alias filter select
    alias filter! select!
  end
end
