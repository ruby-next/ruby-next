[![Gem Version](https://badge.fury.io/rb/ruby-next.svg)](https://rubygems.org/gems/ruby-next) [![Build](https://github.com/palkan/ruby-next/workflows/Build/badge.svg)](https://github.com/palkan/ruby-next/actions)
[![JRuby Build](https://github.com/palkan/ruby-next/workflows/JRuby%20Build/badge.svg)](https://github.com/palkan/ruby-next/actions)

# Ruby Next

> Make older Rubies quack like edge Ruby!

TBD

## Transpiling, or using edge Ruby new syntax features

### Integrating into a gem development

We recommend _pre-transpiling_ source code to work with older versions before releasing it.

This is how you can do that with RubyNext:

- Write source code using the modern/edge Ruby syntax.

- Generate transpiled code by calling `ruby-next nextify ./lib` (e.g., before releasing or pushing to VCS).

This will produce `lib/.rbnext` folder containing the transpiled files, `lib/.rbnext/2.6`, `lib/.rbnext/2.7`. The version in the path indicates which Ruby version is required for the original functionality. Only the source files containing new syntax are added to this folder.

**NOTE:** Do not edit these files manually neither run linters/type checkers/whatever against these files.

- Add the following code to your gem's _entrypoint_ (the file that is required first and contains other `require`-s):

```ruby
require "ruby-next/language/setup"

RubyNext::Language.setup_for_gem
```

The `setup_for_gem` does the following:

- Resolves the current ruby version.
- Checks whether there are directories corresponding to the current and earlier\* Ruby versions within the `.rbnext` folder.
- Add the path to this directory to the `$LOAD_PATH` before the path to the gem's directory.

That's why need an _entrypoint_: all the subsequent `require` calls will load the transpiled files instead of the original ones
due to the way feature resolving works in Ruby (scanning the `$LOAD_PATH` and halting as soon as the matching file is found).

As follows, calling `require_relative` should be avoided.

\* RubyNext doesn't avoid storing duplicates; instead, only the code for the earlier version is created and is assumed to be used with other versions. For example, if the transpiled code is the same for Ruby 2.5 and Ruby 2.6, only the `.rbnext/2.7/path/to/file.rb` is kept. That's why multiple entries are added to the `$LOAD_PATH` (`.rbnext/2.6` and `.rbnext/2.7` in the specified order for Ruby 2.5 and only `.rbnext/2.7` for Ruby 2.6).

## CLI

RubyNext ships with the command-line interface (`ruby-next`) which provides the following functionality:

- `ruby-next nextify` — transpile file or directory into older Rubies (see, for example, the "Integrating into a gem development" section abobe).

It has the following interface:

```sh
$ ruby-next nextify
Usage: ruby-next nextify DIRECTORY_OR_FILE [options]
    -o, --output=OUTPUT              Specify output directory or file
        --min-version=VERSION        Specify the minimum Ruby version to support
        --single-version             Only create one version of a file (for the earliest Ruby version)
    -V                               Turn on verbose mode
```

The behaviour depends on whether you transpile a single file or a directory:

- When transpiling a directory, the `.rbnext` subfolder is created within the target folder with subfolders for each supported Ruby versions (e.g., `.rbnext/2.6`, `.rbnext/2.7`). If you want to create only a signle version (the smallest), you can also pass `--single-version` flag. In that case no version directory is created (i.e., transpiled files go into `.rbnext`).

- When transpiling a file and providing the output path as a _file_ path, only a single version is created. For example:

```sh
$ ruby-next nextify my_ruby.rb -o my_ruby_next.rb -V
Generated: my_ruby_next.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/ruby-next/ruby-next](ttps://github.com/ruby-next/ruby-next).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
