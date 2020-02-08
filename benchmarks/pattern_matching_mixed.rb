# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

# from https://www.ruby-lang.org/en/news/2019/10/22/ruby-2-7-0-preview2-released/
source = %q{
def alice(data)
  case data
  in {name: "Alice", children: [{name: "Bob", age: age}]}
    p "Bob age is #{age}"
  in _
    "No Alice"
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def alice(", "def alice_next("

Benchmark.driver do |x|
  x.prelude %Q{
    require 'json'

    #{source}

    #{next_source}

    data = {
      name: 'Alice',
      children: [{
        name: 'Bob',
        age: 30
      }]
    }

    raise "Assertion failed" if alice(data) != alice_next(data)
  }
  x.report "baseline", %{ alice data }
  x.report "transpiled", %{ alice_next data }
end
