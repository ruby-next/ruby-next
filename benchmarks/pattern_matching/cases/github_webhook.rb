# frozen_string_literal: true

# Hack to use bundled benchmark-driver
module Bundler
  def self.with_unbundled_env(&block); yield; end
end

require "benchmark_driver"

require "ruby-next/language"

source = %{
def call(event)
  case event
    in {type: "issue_comment", action: "created", issue: {user: {login:}}}
      [:issue, login]
    in {type: "pull_request", action: "opened", pull_request: {user: {login:}}}
      [:pr, login]
    end
end
}

next_source = RubyNext::Language.transform(source).gsub! "def call(", "def call_next("

Benchmark.driver do |x|
  x.prelude %Q{
    #{source}

    #{next_source}

    USER = {login: "palkan"}
    PR = {type: "pull_request", action: "opened", pull_request: {user: USER}}
    raise "Assertion failed" if call(PR) != call_next(PR)
  }
  x.report "baseline (last pattern)", %{ call(PR) }
  x.report "transpiled (last pattern)", %{ call_next(PR) }
end
