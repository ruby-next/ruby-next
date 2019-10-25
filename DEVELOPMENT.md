# Development notes

## Testing

We use [ruby/spec][] along with [MSpec][] to
make sure RubyNext passes the latest Ruby specification.

### Running tests

- Clone [MSpec][] into the project's directory:

```sh
git clone https://github.com/ruby/mspec.git mspec
```

- Run tests:

```sh
# all tests
mspec/bin/mspec

# or separate file
mspec/bin/mspec spec/path/to/file
```

### Adding or updating tests

We cherry-pick tests from [ruby/spec][] manually only for the features we need using the following rules:

- Keep the directories and files structure the same as in ruby/spec

- Add `# source: <original link>` pragma at the beginning of every file + blank line

- Add `using RubyNext` right before the test suite + blank line

- Keep the original code as is without changes\*

\* If the original file contains conflicting tests for two different version of Ruby, pick only the latest ones.

The goal is to add an automatic _sync_ task or changes notifier in the future to keep our ruby/spec projection up-to-date.

[ruby/spec]: https://github.com/ruby/spec
[MSpec]: https://github.com/ruby/mspec
