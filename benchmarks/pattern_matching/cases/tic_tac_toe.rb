# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

# Borrowed from https://dev.to/baweaver/ruby-3-pattern-matching-applied-tic-tac-toe-57c9
source = %{
  def call(board)
    case board
    in [
      [MOVE => move, ^move, ^move],
      [_, _, _],
      [_, _, _]
    ]
      [:horizontal, move]
    in [
      [_, _, _],
      [MOVE => move, ^move, ^move],
      [_, _, _]
    ]
      [:horizontal, move]
    in [
      [_, _, _],
      [_, _, _],
      [MOVE => move, ^move, ^move]
    ]
      [:horizontal, move]
    in [
      [MOVE => move, _, _],
      [^move, _, _],
      [^move, _, _]
    ]
      [:vertical, move]
    in [
      [_, MOVE => move, _],
      [_, ^move, _],
      [_, ^move, _]
    ]
      [:vertical, move]
    in [
      [_, _, MOVE => move],
      [_, _, ^move],
      [_, _, ^move]
    ]
      [:vertical, move]
    in [
      [MOVE => move, _, _],
      [_, ^move, _],
      [_, _, ^move]
    ]
      [:diagonal, move]
    in [
      [_, _, MOVE => move],
      [_, ^move, _],
      [^move, _, _]
    ]
      [:diagonal, move]
    else
      [:none, false]
    end
  end
}


next_source = RubyNext::Language.transform(source).gsub! "def call(", "def call_next("

setup = %{
  def board(*rows)
    rows.map(&:chars)
  end

  MOVE = /[XO]/.freeze

  EXAMPLES = {
    straight: board('   ', 'OOO', '   '),
    vertical: board('  X', '  X', '  X'),
    diagonal: board('  X', ' X ', 'X  ')
  }
}

%w[straight vertical diagonal].each do |type|
  Benchmark.driver do |x|
    x.prelude %Q{
      #{setup}

      #{source}

      #{next_source}

      raise "Assertion failed" if call(EXAMPLES[:#{type}]) != call_next(EXAMPLES[:#{type}])
    }

    x.report "baseline (#{type})", %{ call(EXAMPLES[:#{type}]) }
    x.report "transpiled (#{type})", %{ call_next(EXAMPLES[:#{type}]) }
  end
end
