# source: https://github.com/ruby/ruby/blob/a65e8644fb97491314387e4138cabf6378a8e8d5/test/ruby/test_enumerator.rb#L836

require_relative "../../test_unit_to_mspec"
using TestUnitToMspec

require_relative "../../spec_helper"

describe "Enumerator.produce" do
  it "raises without arguments" do
    assert_raise(ArgumentError) { Enumerator.produce }
    assert_raise(ArgumentError) { Enumerator.produce(a: 1, b: 1) {} }
  end

  it "without initial object" do
    passed_args = []
    enum = Enumerator.produce { |obj| passed_args << obj; (obj || 0).succ }
    assert_instance_of(Enumerator, enum)
    assert_equal Float::INFINITY, enum.size
    assert_equal [1, 2, 3], enum.take(3)
    assert_equal [nil, 1, 2], passed_args
  end

  it "with initial object" do
    passed_args = []
    enum = Enumerator.produce(1) { |obj| passed_args << obj; obj.succ }
    assert_instance_of(Enumerator, enum)
    assert_equal Float::INFINITY, enum.size
    assert_equal [1, 2, 3], enum.take(3)
    assert_equal [1, 2], passed_args
  end

  it "with size keyword argument" do
    enum = Enumerator.produce(1, size: 10) { |obj| obj.succ }
    assert_equal 10, enum.size
    assert_equal [1, 2, 3], enum.take(3)

    enum = Enumerator.produce(1, size: -> { 5 }) { |obj| obj.succ }
    assert_equal 5, enum.size

    enum = Enumerator.produce(1, size: nil) { |obj| obj.succ }
    assert_equal nil, enum.size

    enum = Enumerator.produce(1, size: Float::INFINITY) { |obj| obj.succ }
    assert_equal Float::INFINITY, enum.size

    # Without initial value but with size
    enum = Enumerator.produce(size: 3) { |obj| (obj || 0).succ }
    assert_equal 3, enum.size
    assert_equal [1, 2, 3], enum.take(3)
  end

  it "raising StopIteration" do
    words = "The quick brown fox jumps over the lazy dog.".scan(/\w+/)
    enum = Enumerator.produce { words.shift or raise StopIteration }
    assert_equal Float::INFINITY, enum.size
    assert_instance_of(Enumerator, enum)
    assert_equal %w[The quick brown fox jumps over the lazy dog], enum.to_a
  end

  it "raising StopIteration 2" do
    object = [[[["abc", "def"], "ghi", "jkl"], "mno", "pqr"], "stuv", "wxyz"]
    enum = Enumerator.produce(object) { |obj|
      obj.respond_to?(:first) or raise StopIteration
      obj.first
    }
    assert_equal Float::INFINITY, enum.size
    assert_instance_of(Enumerator, enum)
    assert_nothing_raised {
      assert_equal [
        [[[["abc", "def"], "ghi", "jkl"], "mno", "pqr"], "stuv", "wxyz"],
        [[["abc", "def"], "ghi", "jkl"], "mno", "pqr"],
        [["abc", "def"], "ghi", "jkl"],
        ["abc", "def"],
        "abc",
      ], enum.to_a
    }
  end
end
