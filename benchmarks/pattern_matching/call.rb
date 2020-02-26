# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

# Inspired by https://learnyousomeerlang.com/syntax-in-functions#in-case-of
source = %{
def call(val)
  status, headers, body = 200, {}, ""

  case val
    in [String => body,]
      [status, headers, [body]]
    in [Integer => status,]
      [status, headers, [body]]
    in [Integer, String] => response
      [response[0], headers, [response[1]]]
    in [Integer, Hash, String] => response
      headers.merge!(response[1])
      [response[0], headers, [response[2]]]
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def call(", "def call_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    raise "Assertion failed" if call([401]) != call_next([401])
  }
  x.report "baseline (last pattern)", %{ call([201, {}, ""]) }
  x.report "transpiled (last pattern)", %{ call_next([201, {}, ""]) }
end
