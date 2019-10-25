# frozen_string_literal: true

unless Object.new.respond_to?(:then)
  RubyNext.module_eval do
    # Refine object, 'cause refining modules (Kernel) is vulnerable to prepend:
    # - https://bugs.ruby-lang.org/issues/13446
    # - Rails added `Kernel.prepend` in 6.1: https://github.com/rails/rails/commit/3124007bd674dcdc9c3b5c6b2964dfb7a1a0733c
    refine Object do
      alias then yield_self
    end
  end
end
