# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

# Inspired by https://learnyousomeerlang.com/syntax-in-functions#in-case-of
source = %{
def beach(*temperature)
  case temperature
  in :celcius | :c, n if (n >= 20) and (n <= 45)
    :favorable
  in :kelvin | :k, n if (n >= 293) and (n <= 318)
    :scientifically_favorable
  in :fahrenheit | :f, n if (n >= 68) and (n <= 113)
    :favorable_in_us
  else
    :avoid_beach
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def beach(", "def beach_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}
  }
  x.report "baseline", %{ beach :f, 112 }
  x.report "transpiled", %{ beach_next :f, 112 }
end
