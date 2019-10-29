# frozen_string_literal: true

# rubocop:disable Style/LambdaCall
unless proc {}.respond_to?(:<<)
  RubyNext.module_eval do
    refine Proc do
      def <<(other)
        raise TypeError, "callable object is expected" unless other.respond_to?(:call)
        this = self
        proc { |*args, &block| this.(other.(*args, &block)) }
      end

      def >>(other)
        raise TypeError, "callable object is expected" unless other.respond_to?(:call)
        this = self
        proc { |*args, &block| other.(this.(*args, &block)) }
      end
    end
  end
end
# rubocop:enable Style/LambdaCall
