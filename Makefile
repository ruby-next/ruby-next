default: test

test:
	bundle exec mspec/bin/mspec
	CORE_EXT=gem bundle exec mspec/bin/mspec
	CORE_EXT=generated bundle exec mspec/bin/mspec

lint:
	bundle exec rubocop

release: test lint
	gem release ruby-next-core
	gem release ruby-next -t
	git push --tags
