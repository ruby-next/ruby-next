[![Gem Version](https://badge.fury.io/rb/ruby-next.svg)](https://rubygems.org/gems/ruby-next) [![Build](https://github.com/ruby-next/ruby-next/workflows/Build/badge.svg)](https://github.com/ruby-next/ruby-next/actions)
[![JRuby Build](https://github.com/ruby-next/ruby-next/workflows/JRuby%20Build/badge.svg)](https://github.com/ruby-next/ruby-next/actions)

# Ruby Next

<img align="right" height="184"
     title="RubyNext logo" src="./assets/images/logo.svg">

Ruby Next is a collection of **polyfills** and a **transpiler** for supporting the latest and upcoming Ruby features (APIs and syntax) in older versions and alternative implementations. For example, you can use pattern matching and `Kernel#then` in Ruby 2.5 or [mruby][].

Who might be interested in Ruby Next?

- **Ruby gems maintainers** who want to write code using the latest Ruby version but still support older ones.
- **Application developers** who want to give new features a try without waiting for the final release (or, more often, for the first patch).
- **Users of non-MRI implementations** such as [mruby][], [JRuby][], [TruffleRuby][], [Opal][], [RubyMotion][], [Artichoke][], [Prism][].

Ruby Next also aims to help the community to assess new, _experimental_, MRI features by making it easier to play with them.
That's why Ruby Next implements the `trunk` features as fast as possible.

_⚡️ The project is in a **beta** phase. That means that the main functionality has been implemented (see [the list][features]) and APIs shouldn't change a lot in the nearest future. On the other hand, the number of users/projects is not enough to say we're "production-ready". So, can't wait to hear your feedback 🙂_

## Links

- [Ruby Next: Make old Rubies quack like a new one](https://noti.st/palkan/j3i2Dr/ruby-next-make-old-rubies-quack-like-a-new-one) (RubyConf 2019)

## Overview

Ruby Next consists of two parts: **core** and **language**.

Core provides **polyfills** for Ruby core classes APIs via Refinements (default strategy) or core extensions (optionally or for refinement-less environments).

Language is responsible for **transpiling** edge Ruby syntax into older versions. It could be done
programmatically or via CLI. It also could be done in runtime.

Currently, Ruby Next supports Ruby versions 2.5+ (including JRuby 9.2.8+).
Please, [open an issue](https://github.com/ruby-next/ruby-next/issues/new/choose) if you would like us to support older Ruby versions.

## Using only polyfills

First, install a gem:

```ruby
# Gemfile
gem "ruby-next-core"

# gemspec
spec.add_dependency "ruby-next-core"
```

**NOTE:** we use the different _distribution_ gem, `ruby-next-core`, to provide zero-dependency, polyfills-only version.

Then, all you need is to load the Ruby Next:

```ruby
require "ruby-next"
```

And activate the refinement in every file where you want to use it\*:

```ruby
using RubyNext
```

Ruby Next only refines core classes if necessary; thus, this line wouldn't have any effect in the edge Ruby.

**NOTE:** Even if the runtime already contains a monkey-patch with the backported functionality, we consider the method as _dirty_ and activate the refinement for it. Thus, you always have a predictable behaviour. That's why we recommend using refinements for gems development.

Alternatively, you can go with monkey-patches. Just add this line:

```ruby
require "ruby-next/core_ext"
```

The following _rule of thumb_ is recommended when choosing between refinements and monkey-patches:

- Use refinements for libraries development (to avoid conflicts with others code)
- Using core extensions could be considered for application development (no need to think about `using RubyNext`); this approach could potentially lead to conflicts with dependendices (if these dependencies are not using refinements 🙂)
- Use core extensions if refinements are not supported by your platform

[**The list of supported APIs.**][features_core]

## Transpiling, or using edge Ruby syntax features

Ruby Next transpiler relies on two libraries: [parser][] and [unparser][].

**NOTE:** The "official" parser gem only supports the latest stable Ruby version, while Ruby Next aims to support edge and experimental Ruby features. To enable them, you should use our version of Parser (see [instructions](#using-ruby-next-parser) below).

Installation:

```ruby
# Gemfile
gem "ruby-next"

# gemspec
spec.add_dependency "ruby-next"

# or install globally
gem install ruby-next
```

[**The list of supported syntax features.**][features_syntax]

### Integrating into a gem development

We recommend _pre-transpiling_ source code to work with older versions before releasing it.

This is how you can do that with Ruby Next:

- Write source code using the modern/edge Ruby syntax.

- Generate transpiled code by calling `ruby-next nextify ./lib` (e.g., before releasing or pushing to VCS).

This will produce `lib/.rbnext` folder containing the transpiled files, `lib/.rbnext/2.6`, `lib/.rbnext/2.7`. The version in the path indicates which Ruby version is required for the original functionality. Only the source files containing new syntax are added to this folder.

**NOTE:** Do not edit these files manually, either run linters/type checkers/whatever against these files.

- Add the following code to your gem's _entrypoint_ (the file that is required first and contains other `require`-s):

```ruby
require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path
```

The `setup_gem_load_path` does the following:

- Resolves the current ruby version.
- Checks whether there are directories corresponding to the current and earlier\* Ruby versions within the `.rbnext` folder.
- Add the path to this directory to the `$LOAD_PATH` before the path to the gem's directory.

That's why need an _entrypoint_: all the subsequent `require` calls will load the transpiled files instead of the original ones
due to the way feature resolving works in Ruby (scanning the `$LOAD_PATH` and halting as soon as the matching file is found).

**NOTE:** `require_relative` should be avoided due to the way we _hijack_ the features loading mechanism.

\* Ruby Next avoids storing duplicates; instead, only the code for the earlier version is created and is assumed to be used with other versions. For example, if the transpiled code is the same for Ruby 2.5 and Ruby 2.6, only the `.rbnext/2.7/path/to/file.rb` is kept. That's why multiple entries are added to the `$LOAD_PATH` (`.rbnext/2.6` and `.rbnext/2.7` in the specified order for Ruby 2.5 and only `.rbnext/2.7` for Ruby 2.6).

## CLI

Ruby Next ships with the command-line interface (`ruby-next`) which provides the following functionality:

### `ruby-next nextify`

This command allows you to transpile a file or directory into older Rubies (see, for example, the "Integrating into a gem development" section above).

It has the following interface:

```sh
$ ruby-next nextify
Usage: ruby-next nextify DIRECTORY_OR_FILE [options]
    -o, --output=OUTPUT              Specify output directory or file or stdout (use -o stdout for that)
        --min-version=VERSION        Specify the minimum Ruby version to support
        --single-version             Only create one version of a file (for the earliest Ruby version)
        --enable-method-reference    Enable reverted method reference syntax (requires custom parser)
        --[no-]refine                Do not inject `using RubyNext`
    -h, --help                       Print help
    -V                               Turn on verbose mode
```

The behaviour depends on whether you transpile a single file or a directory:

- When transpiling a directory, the `.rbnext` subfolder is created within the target folder with subfolders for each supported Ruby versions (e.g., `.rbnext/2.6`, `.rbnext/2.7`). If you want to create only a single version (the smallest), you can also pass `--single-version` flag. In that case, no version directory is created (i.e., transpiled files go into `.rbnext`).

- When transpiling a file and providing the output path as a _file_ path, only a single version is created. For example:

```sh
$ ruby-next nextify my_ruby.rb -o my_ruby_next.rb -V
RubyNext core strategy: refine
Generated: my_ruby_next.rb
```

### `ruby-next core_ext`

This command could be used to generate a Ruby file with a configurable set of core extensions.

Use this command if you want to backport new Ruby features to Ruby implementations not compatible with RubyGems.

It has the following interface:

```sh
$ ruby-next core_ext
Usage: ruby-next core_ext [options]
    -o, --output=OUTPUT              Specify output file or stdout (default: ./core_ext.rb)
    -l, --list                       List all available extensions
        --min-version=VERSION        Specify the minimum Ruby version to support
    -n, --name=NAME                  Filter extensions by name
    -h, --help                       Print help
    -V                               Turn on verbose mode
```

The most common usecase is to backport the APIs required by pattern matching. You can do this, for example,
by including only monkey-patches containing the `"deconstruct"` in their names:

```sh
ruby-next core_ext -n deconstruct -o pattern_matching_core_ext.rb
```

To list all available (are matching if `--min-version` or `--name` specified) monkey-patches, use the `-l` switch:

```sh
$ ruby-next core_ext -l --name=filter --name=deconstruct
2.6 extensions:
  - ArrayFilter
  - EnumerableFilter
  - HashFilter

2.7 extensions:
  - ArrayDeconstruct
  - EnumerableFilterMap
  - EnumeratorLazyFilterMap
  - HashDeconstructKeys
  - StructDeconstruct
```

## Runtime mode

It is also possible to transpile Ruby source code in run-time via Ruby Next.

All you need is to `require "ruby-next/language/runtime"` as early as possible to hijack `Kernel#require` and friends.
You can also automatically inject `using RubyNext` to every\* loaded file by also adding `require "ruby-next/core/runtime"`.

Since the runtime mode requires Kernel monkey-patching, it should be used carefully. For example, we use it in Ruby Next tests—works perfectly. But think twice before enabling it in production.

Consider using [Bootsnap](#using-with-bootsnap) integration, 'cause its monkey-patching has been bullet-proofed 😉.

\* Ruby Next doesn't hijack every required file but _watches_ only the configured directories: `./app/`, `./lib/`, `./spec/`, `./test/` (relative to the `pwd`). You can configure the watch dirs:

```ruby
RubyNext::Language.watch_dirs << "path/to/other/dir"
```

### Eval & similar

By default, we do not hijack `Kernel.eval` and similar methods due to some limitations (e.g., there is no easy and efficient way to access the caller's scope, or _binding_, and some evaluations relies on local variables).

If you want to support transpiling in `eval`-like methods, opt-in explicitly by activating the refinement:

```ruby
using RubyNext::Language::Eval
```

## Using with Bootsnap

[Bootsnap][] is a great tool to speed-up your application load and it's included into the default Rails Gemfile. It patches Ruby mechanism of loading source files to make it possible to cache the intermediate representation (_iseq_).

Ruby Next provides a specific integration which allows to add a transpiling step to this process, thus making the transpiler overhead as small as possible, because the cached and **already transpiled** version is used if no changes were made.

To enable this integration, add the following line after the `require "bootsnap/setup"`:

```ruby
require "ruby-next/language/bootsnap"
```

**NOTE:** there is no way to invalidate the cache when you upgrade Ruby Next (e.g., due to the bug fixes), so you should do this manually.

## `uby-next`

You can also enable runtime mode by requiring `uby-next` while running a Ruby executable:

```sh
ruby -ruby-next my_ruby_script.rb

# or
RUBYOPT="-ruby-next" ruby my_ruby_script.rb

# or
ruby -ruby-next -e "puts [2, 4, 5].tally"
```

## Unofficial/experimental features

Ruby Next also provides support for some features not-yet-merged into Ruby master (or reverted).

These features require a [custom parser](#using-ruby-next-parser).

Currenly, the only such feature is the [_method reference_ operator](https://bugs.ruby-lang.org/issues/13581):

- Add `--enable-method-reference` option to `nextify` command when using CLI.
- OR add it programmatically when using a runtime mode (see [example](https://github.com/ruby-next/ruby-next/blob/master/default.mspec)).
- OR set `RUBY_NEXT_ENABLE_METHOD_REFERENCE=1` environment variable (works with CLI as well).

## Using Ruby Next parser

### Prerequisites

Our own version of [parser][next_parser] gem is hosted on Github Package Registry. That makes the installation process a bit more complicated than usual.

You must obtain an access token to use it. See the [GPR docs](https://help.github.com/en/github/managing-packages-with-github-package-registry/configuring-rubygems-for-use-with-github-package-registry#authenticating-to-github-package-registry).

### Installing with Bundler

First, configure your bundler to access GPR:

```sh
bundle config --local https://rubygems.pkg.github.com/ruby-next USERNAME:ACCESS_TOKEN
```

Then, add to your Gemfile:

```ruby
source "https://rubygems.pkg.github.com/ruby-next" do
  gem "parser", "~> 2.7.0.100", "< 2.7.1"
end

gem "ruby-next"
```

**NOTE:** we don't add `parser` and `unparser` to the gem's runtime deps, 'cause they're not necessary if you only need polyfills.

### Installing globally via `gem`

You can install `ruby-next` globally by running the following commands:

```sh
gem install parser -v "~> 2.7.0.100" -v "< 2.7.1" --source "https://USERNAME:ACCESS_TOKEN@rubygems.pkg.github.com/ruby-next"
gem install ruby-next
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/ruby-next/ruby-next](ttps://github.com/ruby-next/ruby-next).

See also the [development guide](./DEVELOPMENT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[features]: ./SUPPORTED_FEATURES.md
[features_core]: ./SUPPORTED_FEATURES.md#Core
[features_syntax]: ./SUPPORTED_FEATURES.md#Syntax
[mruby]: https://mruby.org
[JRuby]: https://www.jruby.org
[TruffleRuby]: https://github.com/oracle/truffleruby
[Opal]: https://opalrb.com
[RubyMotion]: http://www.rubymotion.com
[Artichoke]: https://github.com/artichoke/artichoke
[Prism]: https://github.com/prism-rb/prism
[parser]: https://github.com/whitequark/parser
[unparser]: https://github.com/mbj/unparser
[next_parser]: https://github.com/ruby-next/parser
[Bootsnap]: https://github.com/Shopify/bootsnap
