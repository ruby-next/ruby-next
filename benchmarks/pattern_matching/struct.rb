# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

source = %q{
s = Struct.new(:a, :b, keyword_init: true)

def struct_match(data)
  case data
  in a:, c:
    flunk
  in a:, b:, c:
    flunk
  in b:
    b == 1
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def struct_match(", "def struct_match_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    data = s[a: 0, b: 1]

    # fail fast if expection is raised
    struct_match(data)
    struct_match_next(data)
  }

  x.report "baseline", %{ struct_match(data) }
  x.report "transpiled", %{ struct_match_next(data) }
end