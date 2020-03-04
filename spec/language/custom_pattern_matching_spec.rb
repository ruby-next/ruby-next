require_relative '../test_unit_to_mspec'

using TestUnitToMspec

# These tests are not copied from ruby/ruby
describe "custom tests" do
  it "array pattern multiple clauses" do
    # multiple clauses with arrays
    assert_block do
      case [0, 1, 2]
      in [0, 2, *a]
        false
      in [0, *a]
        a == [1, 2]
      end
    end

    #  multiple clauses with hash
    assert_block do
      case {a: 0, b: 1}
        in a: 1, **b
          false
        in a:, **b
          a == 0 && b == {b: 1}
        end
    end
  end

  it "hash pattern with multiple clauses" do
    s = Struct.new(:a, :b, keyword_init: true)
    assert_block do
      case s[a: 0, b: 1]
      in a:, c:
        false
      in a:, b:, c:
        false
      in b:
        b == 1
      end
    end
  end

  it "array pattern with different sizes" do
    assert_block do
      case [0, 1, 2]
      in [0]
        false
      in [0, 1]
        false
      else
        true
      end
    end
  end

  it "in operator" do
    # in with hash
    assert_block do
      {a: [0, 1, 2]} in {a:}
      a == [0, 1, 2]
    end

    # in with hash and array rest
    assert_block do
      {a: [0, 1, 2]} in {a: [0, *r]}
      r == [1, 2]
    end
  end

  it "mixed clauses" do
    s = Struct.new(:x, :y)
    assert_block do
      case s[0, "m"]
        in x: 1, **b
          false
        in *b, "m"
          b == [0]
        end
    end
  end

  it "nested pattern matching" do
    assert_block do
      val = [0, 1, 2]
      case val
      in [0, 0, *a]
        false
      else
        val.shift

        case val
        in [1, 2]
          true
        end
      end
    end
  end

  it "nested alternation" do
    assert_block do
      case [[1], ["2"]]
        in [[0] | nil, _]
          false
        in [[1], [1]]
          false
        in [[1], [2 | "2"]]
          true
      end
    end

    assert_block do
      case [1, 2]
        in [0, _] | {a: 0}
          false
        in {a: 1, b: 2} | [1, 2]
          true
      end
    end
  end

  describe "multi-level patterns" do
    it "with arrays" do
      assert_block do
        case [[1], [2]]
          in [[0], _]
            false
          in [[1], [1]]
            false
          in [[1], [2]]
            true
        end
      end
    end

    it "with hashes" do
      assert_block do
        case {a: {a: 1, b: 1}, b: {a: 1, b: 2}}
          in {a: {a: 0}}
            false
          in {a: {a: 1}, b: {b: 1}}
            false
          in {a: {a: 1}, b: {b: 2}}
            true
        end
      end
    end
  end

  describe "AS pattern" do
    it "can be used with array pattern" do
      eval(<<~RUBY, binding).should == [2, 3]
        case [1, [2, 3]]
          in [Integer, Array] => ary
            ary[1]
        end
      RUBY
    end

    it "can be used with array pattern element" do
      eval(<<~RUBY, binding).should == 1
        case [1]
          in [Integer => res]
            res
        end
      RUBY
    end

    it "can be used with hash pattern" do
      eval(<<~RUBY, binding).should == [2, 3]
        case {a: 1, b: [2, 3]}
          in {a: Integer, b: Array} => data
            data[:b]
        end
      RUBY
    end

    it "can be used with hash pattern key" do
      eval(<<~RUBY, binding).should == 1
        case {a: 1}
          in {b: NilClass}
            0
          in {a: Integer => res}
            res
        end
      RUBY
    end
  end
end
