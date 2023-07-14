source "https://rubygems.org"

# Specify your gem's dependencies in rubanok.gemspec
gemspec name: "ruby-next-core"

gem "benchmark_driver"

gem "pry-byebug", platform: :mri
eval_gemfile "gemfiles/rubocop.gemfile"

# For compatibility tests
gem "zeitwerk", platform: [:mri, :truffleruby]
gem "bootsnap", platform: [:mri, :truffleruby]
gem "pry", "> 0.13.1"
