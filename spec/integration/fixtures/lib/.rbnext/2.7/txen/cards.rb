using RubyNext;module Txen
  module Cards
    def self.call(id)
      __matchee__ = id
      if (((((((("2" === __matchee__) || ("3" === __matchee__)) || ("4" === __matchee__)) || ("5" === __matchee__)) || ("6" === __matchee__)) || ("7" === __matchee__)) || ("9" === __matchee__)) || ("10" === __matchee__))
        id.to_i
      else
        if ((("jack" === __matchee__) || ("queen" === __matchee__)) || ("king" === __matchee__))
          10
        else
          if ("ace" === __matchee__)
            11
          else
            Kernel.raise(NoMatchingPatternError, __matchee__.inspect)
          end
        end
      end
    end
  end
end