# frozen_string_literal: true

# This is a regression test for an edge case when patch version for some rewriter is not 0
def delegate(...)
  foo(...)
end

def foo(a)
  case a
  in Integer
    a * 2
  end
end

if ARGV.size == 1
  p foo(ARGV[0])
end
