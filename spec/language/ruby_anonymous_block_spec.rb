# source: https://github.com/ruby/ruby/blob/4adb012926f8bd6011168327d8832cf19976de40/test/ruby/test_syntax.rb#L69

require_relative '../test_unit_to_mspec'

using RubyNext::Language::InstanceEval
using TestUnitToMspec

describe "def foo(&) = bar(&)" do
  it "syntax" do
    assert_syntax_error("def b; c(&); end", /no anonymous block parameter/)
    assert_separately([], "#{<<-"begin;"}\n#{<<-'end;'}")
    begin;
        def b(&); c(&) end
        def c(&); yield 1 end
        a = nil
        b{|c| a = c}
        assert_equal(1, a)
    end;
  end
end
