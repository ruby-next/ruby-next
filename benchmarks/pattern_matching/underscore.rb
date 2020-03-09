# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

source = %{
def call(val)
  case val
    in [_]
      1
    in [_, _]
      2
    in [_, _, _]
      3
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def call(", "def call_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    raise "Assertion failed" if call([1, 2, 3]) != call_next([1, 2, 3])
  }
  x.report "baseline (last pattern)", %{ call([201, :x, ""]) }
  x.report "transpiled (last pattern)", %{ call_next([201, :x, ""]) }
end
