require_relative './string'

module RefinementSpecs
  using StringExt

  module Import
    class A
      def initialize
        @baz = 42
        @fuu = 2021
      end

      def foo
        "Original".decapitalize
      end
    end

    module B
      BAR = "bar"

      def bar(); "#{foo}:#{BAR}"; end

      # attr_reader :fuu
      # define_method(:baz) { @baz }
    end

    module C
      refine A do
        import_methods B

        def foo
          "Refined".decapitalize
        end
      end
    end

    module D
      refine A do
        include B

        def foo
          "Refined".decapitalize
        end
      end
    end

    module UsingC
      using C

      def self.call_bar
        A.new.bar
      end

      def self.call_baz
        A.new.baz
      end

      def self.call_fuu
        A.new.fuu
      end
    end

    module UsingD
      using D

      def self.call_bar
        A.new.bar
      end

      def self.call_baz
        A.new.baz
      end

      def self.call_fuu
        A.new.fuu
      end
    end
  end
end
