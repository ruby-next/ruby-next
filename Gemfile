source "https://rubygems.org"

# Specify your gem's dependencies in rubanok.gemspec
gemspec

gem "benchmark_driver"

gem "pry-byebug", platform: :mri
eval_gemfile "gemfiles/rubocop.gemfile"

source "https://rubygems.pkg.github.com/ruby-next" do
  gem "parser", "~> 2.7.0.100"
end
