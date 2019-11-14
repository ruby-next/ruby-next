# frozen_string_literal: true

unless [].respond_to?(:filter)
  RubyNext.module_eval do
    begin
      refine Enumerable do
        alias filter select
      end
    # Module refinements could be unsupported
    rescue TypeError
    end

    # Refine Array seprately, 'cause refining modules is vulnerable to prepend:
    # - https://bugs.ruby-lang.org/issues/13446
    #
    # Also, Array also have `filter!`
    refine Array do
      alias filter select
      alias filter! select!
    end

    refine Hash do
      alias filter select
      alias filter! select!
    end
  end
end
