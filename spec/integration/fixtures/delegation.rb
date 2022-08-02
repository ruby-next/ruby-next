# frozen_string_literal: true

def repeat(n, word: "bar") = word * n

def repeats(...) = repeat(...)

def repeatOnce(...) = repeats(1, ...)

class Repeater
  def prefixed(prefix, ...)
    "#{prefix}#{repeats(...)}"
  end

  def self.wrapped(prefix, suffix, ...)
    "#{prefix}#{repeats(...)}#{suffix}"
  end
end
