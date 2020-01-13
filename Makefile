default: test

test:
	bundle exec mspec/bin/mspec

lint:
	bundle exec rubocop

release: test lint
	gem release ruby-next-core
	gem release ruby-next -t
	gem push --tags
