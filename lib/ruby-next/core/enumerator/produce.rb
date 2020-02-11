# frozen_string_literal: true

RubyNext::Core.patch Enumerator.singleton_class,
  name: "EnumeratorProduce",
  singleton: Enumerator,
  version: "2.7",
  supported: Enumerator.respond_to?(:produce),
  location: [__FILE__, __LINE__ + 2] do
  <<~'RUBY'
    # Based on https://github.com/zverok/enumerator_generate
    def produce(*rest, &block)
      raise ArgumentError, "wrong number of arguments (given #{rest.size}, expected 0..1)" if rest.size > 1
      raise ArgumentError, "No block given" unless block

      Enumerator.new(Float::INFINITY) do |y|
        val = rest.empty? ? yield() : rest.pop

        loop do
          y << val
          val = yield(val)
        end
      end
    end
  RUBY
end
