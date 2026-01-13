# frozen_string_literal: true

RubyNext::Core.patch Enumerator.singleton_class, method: :produce, singleton: Enumerator,
  supported: Enumerator.respond_to?(:produce) && (
    begin
      Enumerator.produce(a: 1, b: 1) {}
      false
    rescue ArgumentError
      true
    end
  ),
  version: "4.0" do
  <<-'RUBY'
def produce(*rest, size: Float::INFINITY, &block)
  raise ArgumentError, "wrong number of arguments (given #{rest.size}, expected 0..1)" if rest.size > 1
  raise ArgumentError, "No block given" unless block

  Enumerator.new(size) do |y|
    val = rest.empty? ? yield() : rest.pop

    loop do
      y << val
      val = yield(val)
    end
  end
end
  RUBY
end
