source "https://rubygems.org"

# Specify your gem's dependencies in ruby-next-core.gemspec
gemspec name: "ruby-next-core"

gem "benchmark_driver"

gem "pry-byebug", platform: :mri
eval_gemfile "gemfiles/rubocop.gemfile"

# For compatibility tests
gem "zeitwerk", platform: [:mri, :truffleruby]
gem "bootsnap", platform: [:mri, :truffleruby]
gem "pry", "> 0.13.1"

# Using next-gen Ruby parser
if ENV["PRISM"] == "true"
  if File.directory?("../parser-prism")
    gem "parser-prism", path: "../parser-prism"
  else
    gem "parser-prism", github: "ruby-next/parser-prism"
  end
end
