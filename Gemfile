source "https://rubygems.org"

# Specify your gem's dependencies in rubanok.gemspec
gemspec name: "ruby-next-core"

gem "benchmark_driver"

gem "pry-byebug", platform: :mri
eval_gemfile "gemfiles/rubocop.gemfile"

unless ENV["USE_RUBYGEMS_PARSER"] == "1"
  source "https://rubygems.pkg.github.com/ruby-next" do
    gem "parser", "~> 2.7.0.102"
  end
else
  gem "parser", "~> 2.7.0.5", "< 2.7.0.100"
end

# For compatibility tests
gem "zeitwerk", platform: :mri
gem "bootsnap", platform: :mri
