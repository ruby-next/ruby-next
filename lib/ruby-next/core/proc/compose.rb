# frozen_string_literal: true

# rubocop:disable Style/LambdaCall
RubyNext::Core.patch Proc,
  name: "ProcCompose",
  version: "2.6",
  supported: proc {}.respond_to?(:<<),
  location: [__FILE__, __LINE__ + 2] do
  <<~RUBY
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
  RUBY
end
# rubocop:enable Style/LambdaCall
