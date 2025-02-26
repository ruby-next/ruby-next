default: lint test

test:
	bundle exec bin/mspec

test-all:
	bundle exec bin/mspec
	CORE_EXT=gem bundle exec bin/mspec :language :core
	CORE_EXT=generated bundle exec bin/mspec :language :core

lint:
	RUBY_NEXT_PROPOSED=true bundle exec rubocop

transpile:
	bundle exec bin/ruby-next nextify --transpile-mode=rewrite --min-version=2.0 lib/ -V

transpile-language-specs:
	bundle exec bin/ruby-next nextify --transpile-mode=rewrite --min-version=2.0 spec/language/ruby20 -V

release: test lint transpile
	gem release ruby-next-core
	gem release ruby-next -t
	git push
	git push --tags

ci-release: test lint transpile
	gem release ruby-next-core
	gem release ruby-next
