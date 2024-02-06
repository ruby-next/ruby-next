source "https://rubygems.org"

# Specify your gem's dependencies in ruby-next-core.gemspec
gemspec name: "ruby-next-core"

gem "benchmark_driver"

gem "pry-byebug", platform: :mri
eval_gemfile "gemfiles/rubocop.gemfile"

# For compatibility tests
gem "zeitwerk"
gem "bootsnap", platform: [:mri, :truffleruby]
gem "pry", "> 0.13.1"

# Using next-gen Ruby parser
if ENV["PRISM"] == "true"
  if File.directory?("../prism")
    gem "prism", path: "../prism"
  else
    gem "prism", "~> 0.21"
  end
end
