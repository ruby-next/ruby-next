require_relative '../test_unit_to_mspec'

using TestUnitToMspec

# These tests are not copied from ruby/ruby
describe "custom tests" do
  it "multiple clauses" do
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
end
