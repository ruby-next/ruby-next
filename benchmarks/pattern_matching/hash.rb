# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

# from https://www.toptal.com/ruby/ruby-pattern-matching-tutorial
source = %q{
def display_name(name_hash)
  case name_hash
  in {username: username}
    username
  in {nickname: nickname, realname: {first: first, last: last}}
    "#{nickname} #{first} #{last}"
  in {first: first, last: last}
    "#{first} #{last}"
  else
    'New User'
  end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def display_name(", "def display_name_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    data = {
      nickName: 'Tae',
      realName: {firstName: 'Noppakun', lastName: 'Wongsrinoppakun'},
      username: 'tae8838'
    }

    raise "Assertion failed" if display_name(data) != display_name_next(data)
  }

  x.report "baseline (first match)", %{ display_name data }
  x.report "transpiled (first match)", %{ display_name_next data }
end

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    data = {
      nickname: 'Tae',
      realname: {first: 'Noppakun', last: 'Wongsrinoppakun'}
    }

    raise "Assertion failed" if display_name(data) != display_name_next(data)
  }

  x.report "baseline (second match)", %{ display_name data }
  x.report "transpiled (second match)", %{ display_name_next data }
end
