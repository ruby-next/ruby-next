[![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](https://cultofmartians.com/tasks/ruby-next-cli-rewriters.html#task)
[![Gem Version](https://badge.fury.io/rb/ruby-next.svg)](https://rubygems.org/gems/ruby-next) [![Build](https://github.com/ruby-next/ruby-next/workflows/Build/badge.svg)](https://github.com/ruby-next/ruby-next/actions)
[![JRuby Build](https://github.com/ruby-next/ruby-next/workflows/JRuby%20Build/badge.svg)](https://github.com/ruby-next/ruby-next/actions?query=workflow%3A%22TruffleRuby+Build%22)
[![TruffleRuby Build](https://github.com/ruby-next/ruby-next/workflows/TruffleRuby%20Build/badge.svg)](https://github.com/ruby-next/ruby-next/actions?query=workflow%3A%22TruffleRuby+Build%22)

# Ruby Next

<img align="right" height="184"
     title="Ruby Next logo" src="./assets/images/logo.svg">

Ruby Next is a **transpiler** and a collection of **polyfills** for supporting the latest and upcoming Ruby features (APIs and syntax) in older versions and alternative implementations. For example, you can use pattern matching and `Kernel#then` in Ruby 2.5 or [mruby][].

Who might be interested in Ruby Next?

- **Ruby gems maintainers** who want to write code using the latest Ruby version but still support older ones.
- **Application developers** who want to give new features a try without waiting for the final release (or, more often, for the first patch).
- **Users of non-MRI implementations** such as [mruby][], [JRuby][], [TruffleRuby][], [Natalie][], [Opal][], [RubyMotion][], [Artichoke][], [Prism][].
- **Ruby syntax enthusiasts** who want to experiment with [custom syntax extensions](#custom-syntax-rewriters) 👩‍🔬👨‍🔬.

Ruby Next also aims to help the community to assess new, _experimental_, MRI features by making it easier to play with them.
That's why Ruby Next implements the `master` features as fast as possible.

See also a companion library (extracted from Ruby Next) that provides **code loading hooks** for your needs—[require-hooks][require-hooks].

Read more about the motivation behind the Ruby Next in this post: [Ruby Next: Make all Rubies quack alike](https://evilmartians.com/chronicles/ruby-next-make-all-rubies-quack-alike).

<table style="border:none;">
<tr>
<td>
     <a href="https://evilmartians.com/?utm_source=ruby-next">
          <img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
     </a>
</td>
<td>
     <a href="http://www.digitalfukuoka.jp/topics/169">
          <img src="http://www.digitalfukuoka.jp/javascripts/kcfinder/upload/images/excellence.jpg" width="200">
     </a>
</td>
</tr>
</table>

## Posts

- [Ruby Next: Make all Rubies quack alike](https://evilmartians.com/chronicles/ruby-next-make-all-rubies-quack-alike)

## Talks

- [Ruby Next: Make old Rubies quack like a new one](https://noti.st/palkan/j3i2Dr/ruby-next-make-old-rubies-quack-like-a-new-one) (RubyConf 2019)

## Examples

- Ruby gems
  - [action_policy](https://github.com/palkan/action_policy)
  - [anyway_config](https://github.com/palkan/anyway_config)
  - [graphql-fragment_cache](https://github.com/DmitryTsepelev/graphql-ruby-fragment_cache)
- Rails applications
  - [anycable_rails_demo](https://github.com/anycable/anycable_rails_demo)
- mruby
  - [ACLI](https://github.com/palkan/acli)

_Please, submit a PR to add your project to the list!_

## Table of contents

- [Overview](#overview)
- [Quick start](#quick-start)
- [Polyfills](#using-only-polyfills)
- [Transpiling](#transpiling)
  - [Modes](#transpiler-modes)
  - [CLI](#cli)
  - [Using in gems](#integrating-into-a-gem-development)
  - [Runtime usage](#runtime-usage)
  - [`ruby -ruby-next`](#uby-next)
  - [Logging & Debugging](#logging-and-debugging)
- [RuboCop](#rubocop)
- [Using with IRB](#irb)
- [Using with Pry](#pry)
- [Using with EOL Rubies](#using-with-eol-rubies)
- [Proposed & edge features](#proposed-and-edge-features)
- [Custom syntax rewriters](#custom-syntax-rewriters)
- [Known limitations](#known-limitations)

## Overview

Ruby Next consists of two parts: **core** and **language**.

Core provides **polyfills** for Ruby core classes APIs via Refinements (default strategy) or core extensions (optionally or for refinement-less environments).

Language is responsible for **transpiling** edge Ruby syntax into older versions. It could be done
programmatically or via CLI. It also could be done in runtime.

Currently, Ruby Next supports Ruby versions 2.3+, including JRuby 9.2.8+ and TruffleRuby 20.1+ (with some limitations). Support for older versions (<2.5) slightly differs though ([see below](#using-with-eol-rubies)). Versions between 2.0 and 2.3 may work but we no longer test against them.

Please [open an issue](https://github.com/ruby-next/ruby-next/issues/new/choose) or join the discussion in the existing issues if you would like us to support older Ruby versions.

## Quick start

The quickest way to start experimenting with Ruby Next is to install the gem and run a sample script. For example:

```sh
# Install Ruby Next globally
$ gem install ruby-next

# Call ruby with -ruby-next flag
$ ruby -ruby-next -e "
greet = proc do
  case it
    in hello: hello if hello =~ /human/i
      '🙂'
    in hello: 'martian'
      '👽'
    end
end

puts greet.call(hello: 'martian')
"

=> 👽
```

## Using only polyfills

First, install a gem:

```ruby
# Gemfile
gem "ruby-next-core"

# gemspec
spec.add_dependency "ruby-next-core", "~> 1.0"
```

**NOTE:** we use a different gem for _distribution_, `ruby-next-core`, to provide a zero-dependency, polyfills-only version.

Then, all you need is to load Ruby Next:

```ruby
require "ruby-next"
```

And activate the refinement in every file where you want to use it\*:

```ruby
using RubyNext
```

Ruby Next only refines core classes if necessary; thus, this line wouldn't have any effect in edge Ruby.

**NOTE:** Even if the runtime already contains a monkey-patch with the backported functionality, we consider the method as _dirty_ and activate the refinement for it. Thus, you always have predictable behaviour. That's why we recommend using refinements for gem development.

Alternatively, you can go with monkey-patches. Just add this line:

```ruby
require "ruby-next/core_ext"
```

The following _rule of thumb_ is recommended when choosing between refinements and monkey-patches:

- Use refinements for library development (to avoid conflicts with others' code)
- Using core extensions could be considered for application development (no need to think about `using RubyNext`); this approach could potentially lead to conflicts with dependencies (if these dependencies are not using refinements 🙂)
- Use core extensions if refinements are not supported by your platform

**NOTE:** _Edge_ APIs (i.e., from the Ruby's master branch) are included by default.

[**The list of supported APIs.**][features_core]

### Data backport

Ruby 3.2 has introduced a new core class—[Data](https://bugs.ruby-lang.org/issues/16122). Ruby Next provides a backport functionality which is automatically activated when you `require "ruby-next"` **if and only if the constant is undefined**. If you want to use a custom backport, make sure you loaded it first.

If you want to opt-out from loading Data backport, you must set the `RUBY_NEXT_DISABLE_DATA` env variable to `true`.

#### Known limitations when using Data

Currently, passing Hash as a last positional argument to `Data.new` is not supported in Ruby <3.0 (due to the difference in keyword arguments handling). We recommend always using keyword arguments when initializing Data objects.

## Transpiling

Ruby Next allows you to transpile\* edge Ruby syntax to older versions.

Transpiler relies on two libraries: [parser][] and [unparser][].

**NOTE:** The "official" parser gem only supports the latest stable Ruby version, while Ruby Next aims to support edge and experimental Ruby features. To enable them, you should use our version of Parser (see [instructions](#using-ruby-next-parser) below).

Installation:

```ruby
# Gemfile
gem "ruby-next", "~> 1.0"

# gemspec
spec.add_dependency "ruby-next", "~> 1.0"
```

```sh
# or install globally
gem install ruby-next
```

[**The list of supported syntax features.**][features_syntax]

### Transpiler modes

Since v1.0, Ruby Next only support the _rewrite_ mode, i.e., the code transformations are applied directly to the original source code. This allows us to keep formatting as close as possible to the original code.

The main benefit of the rewrite mode is that it preserves the original code line numbers and layout, which is especially useful in debugging.

The legacy AST mode (regenerating source code from the modified abstract syntax tree) is deprecated (though still supported).

## CLI

Ruby Next ships with the command-line interface (`ruby-next`) which provides the following functionality:

### `ruby-next nextify`

This command allows you to transpile a file or directory into older Rubies (see, for example, the "Integrating into a gem development" section above).

It has the following interface:

```sh
$ ruby-next nextify
Usage: ruby-next nextify DIRECTORY_OR_FILE [options]
    -o, --output=OUTPUT              Specify output directory or file or stdout
        --min-version=VERSION        Specify the minimum Ruby version to support
        --single-version             Only create one version of a file (for the earliest Ruby version)
        --overwrite                  Overwrites the original file with one version of --single-version (works only with --single-version or --rewrite)
        --edge                       Enable edge (master) Ruby features
        --proposed                   Enable proposed/experimental Ruby features
        --[no-]refine                Do not inject `using RubyNext`
        --list-rewriters             List available rewriters
        --rewrite=REWRITERS...       Specify particular Ruby features to rewrite
        --import-rewriter=PATHS...   Specify the paths to custom rewriters to load
    -h, --help                       Print help
    -V                               Turn on verbose mode
        --dry-run                    Print verbose output without generating files
```

The behaviour depends on whether you transpile a single file or a directory:

- When transpiling a directory, the `.rbnext` subfolder is created within the target folder with subfolders for each supported Ruby versions (e.g., `.rbnext/2.7`, `.rbnext/3.1`, `.rbnext/3.4`, etc.). If you want to create only a single version (the smallest), you can also pass `--single-version` flag. In that case, no version directory is created (i.e., transpiled files go into `.rbnext`).

- When transpiling a file and providing the output path as a _file_ path, only a single version is created. For example:

```sh
$ ruby-next nextify my_ruby.rb -o my_ruby_next.rb -V
Ruby Next core strategy: refine
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
        --dry-run                    Print verbose output without generating files
```

The most common use-case is to backport the APIs required by pattern matching. You can do this, for example,
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

...
```

### CLI configuration file

You can define CLI options in the `.rbnextrc` file located in the root of your project to avoid adding them every time you run `ruby-next`.

Configuration file is a YAML with commands as keys and options as multiline strings:

```yml
# ./.rbnextrc

nextify: |
  --min-version=2.7
  --edge
```

**NOTE:** The `nextify` section is also used by auto-transpiling when installing the gem from source and by runtime transpiling.

## Integrating into a gem development

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

If you're using [runtime mode](#runtime-usage) a long with `setup_gem_load_path` (e.g., in tests), the transpiled files are ignored (i.e., we do not modify `$LOAD_PATH`).

\* Ruby Next avoids storing duplicates; instead, only the code for the earlier version is created and is assumed to be used with other versions. For example, if the transpiled code is the same for Ruby 2.5 and Ruby 2.6, only the `.rbnext/2.7/path/to/file.rb` is kept. That's why multiple entries are added to the `$LOAD_PATH` (`.rbnext/2.6`, `.rbnext/2.7`, and `.rbnext/3.0` in the specified order for Ruby 2.5, and `.rbnext/2.7` and `.rbnext/3.0` for Ruby 2.6).

### Transpiled files vs. VCS vs. installing from source

It's a best practice to not keep generated files in repositories. In case of Ruby Next, it's a `lib/.rbnext` folder.

We recommend adding this folder only to the gem package (i.e., it should be added to your `spec.files`) and ignore it in your VCS (e.g., `echo ".rbnext/" >> .gitignore`). That would make transpiled files available in releases without polluting your repository.

What if someone decides to install your gem from the VCS source? They would likely face some syntax errors due to the missing transpiled files.

To solve this problem, Ruby Next _tries_ to transpile the source code when you call `#setup_gem_load_path`. It does this by calling `bundle exec ruby-next nextify <lib_dir> -o <next_dir>`. We make the following assumptions:

- We are in the Bundler context (since that's the most common way of installing gems from source).
- Our Gemfile contains `ruby-next` gem.
- We use [`.rbnextrc`](#CLI-configuration-file) for transpiling options.

If the command fails we warn the end user.

This feature, _auto-transpiling_, is **disabled** by default (will likely be enabled in future versions). You can enable it by calling `RubyNext::Language.setup_gem_load_path(transpile: true)`.

## Runtime usage

It is also possible to transpile Ruby source code in run-time via Ruby Next.

All you need is to `require "ruby-next/language/runtime"` to hijack `Kernel#require` and friends before loading the files you want to transpile. You can also automatically inject `using RubyNext` to every\* loaded file by also adding `require "ruby-next/core/runtime"`.

Runtime mode is backed by [require-hooks][require-hooks]—a standalone gem which has been extracted from Ruby Next. Depending on the current runtime, it picks an optimal strategy for hijacking the loading mechanism. Please, refer to its documentation for more details.

\* Ruby Next doesn't hijack every required file but only the configured directories: `./app/`, `./lib/`, `./spec/`, `./test/` (relative to the `pwd`). It also excludes the `./vendor/bundle` directory by default.

You can customize target files via the `include_patterns` and `exclude_patterns` configuration options:

```ruby
RubyNext::Language.include_patterns << "path/to/other/dir/*.rb"
RubyNext::Language.exclude_patterns << "path/to/other/dir/subdir/*"
```

**NOTE:** Directories MUST be configured before requiring `ruby-next/language/runtime`.

### Eval & similar

By default, we do not hijack `Kernel.eval` and similar methods due to some limitations (e.g., there is no easy and efficient way to access the caller's scope, or _binding_, and some evaluations relies on local variables).

If you want to support transpiling in `eval`-like methods, opt-in explicitly by activating the refinement:

```ruby
using RubyNext::Language::Eval
```

## `uby-next`

_This is [not a typo](https://github.com/ruby-next/ruby-next/pull/8), that’s the way `ruby -ruby-next` works: it’s equal to `ruby -r uby-next`, and [`uby-next.rb`](https://github.com/ruby-next/ruby-next/blob/master/lib/uby-next.rb) is a special file that activates the runtime mode._

You can also enable runtime mode by requiring `uby-next` while running a Ruby executable:

```sh
ruby -ruby-next my_ruby_script.rb

# or
RUBYOPT="-ruby-next" ruby my_ruby_script.rb

# or
ruby -ruby-next -e "puts [2, 4, 5].tally"
```

**NOTE:** running Ruby scripts directly or executing code via `-e` option is not supported in TruffleRuby. You can still use `-ruby-next` to transpile required files, e.g.:

```sh
ruby -ruby-next -r my_ruby_script.rb -e "puts my_method"
```

## Logging and debugging

Ruby Next prints some debugging information when fails to load a file in the runtime mode (and fallbacks to the built-in loading mechanism).

You can disable these warnings either by providing the `RUBY_NEXT_WARN=false` env variable or by setting `RubyNext.silence_warnings = true` in your code.

You can also enable transpiled source code debugging by setting the `RUBY_NEXT_DEBUG=true` env variable. When it's set, Ruby Next prints the transpiled code before loading it.

You can use a file pattern as the value for the env var to limit the output: for example, `RUBY_NEXT_DEBUG=my_script.rb`.

## RuboCop

Since Ruby Next provides support for features not available in RuboCop yet, you need to add a patch for compatibility.
In you `.rubocop.yml` add the following:

```yml
require:
  - ruby-next/rubocop
```

You must set `TargetRubyVersion: next` to make RuboCop use a Ruby Next parser.

Alternatively, you can load the patch from the command line by running: `rubocop -r ruby-next/rubocop ...`.

We recommend using the latest RuboCop version, 'cause it has support for new nodes built-in.

Also, when pre-transpiling source code with `ruby-next nextify`, we suggest ignoring the transpiled files:

```yml
AllCops:
  Exclude:
    - 'lib/.rbnext/**/*'
```

**NOTE:** you need `ruby-next` gem available in the environment where you run RuboCop (having `ruby-next-core` is not enough).

## IRB

Ruby Next supports IRB. In order to enable edge Ruby features for your REPL, add the following line to your `.irbrc`:

```ruby
require "ruby-next/irb"
```

Alternatively, you can require it at startup:

```sh
irb -r ruby-next/irb
# or
irb -ruby-next/irb
```

## Pry

Ruby Next supports Pry. In order to enable edge Ruby features for your REPL, add the following line to your `.pryrc`:

```ruby
require "ruby-next/pry"
```

Alternatively, you can require it at startup:

```sh
pry -r ruby-next/pry
# or
pry -ruby-next/pry
```

## Using with EOL Rubies

We currently provide support for Ruby 2.3+.

**NOTE:** By "support" here we mean using `ruby-next` CLI and runtime transpiling. Transpiled code may run on Ruby 2.0+.

Ruby Next itself relies on 2.5 features and contains polyfills only for version 2.5+ (and that won't change).
Thus, to make it work with <2.5 we need to backport some APIs ourselves.

The recommended way of doing this is to use [backports][] gem. You need to load backports **before Ruby Next**.

When using runtime features, you should do the following:

```ruby
# first, require backports upto 2.5
require "backports/2.5"
# then, load Ruby Next
require "ruby-next"
# if you need 2.6+ APIs, add Ruby Next core_ext
require "ruby-next/core_ext"
# then, load runtime transpiling
require "ruby-next/language/runtime"
# or
require "ruby-next/language/bootsnap"
```

To load backports while using `ruby-next nextify` command, you must configure the environment variable:

```sh
RUBY_NEXT_CORE_STRATEGY=backports ruby-next nextify lib/
```

**NOTE:** Make sure you have `backports` gem installed globally or added to your bundle (if you're using `bundle exec ruby-next ...`).

**NOTE:** For Ruby 2.2, safe navigation operator (`&.`) and squiggly heredocs (`<<~TXT`) support is provided.

**IMPORTANT:** Unparser `~> 0.4.8` is required to run the transpiler on Ruby <2.4.

## Proposed and edge features

Ruby Next aims to bring edge and proposed features to Ruby community before they (hopefully) reach an official Ruby release.
This includes:

- Features already merged to [master](https://github.com/ruby/ruby) (_edge_)
- Features proposed in [Ruby bug tracker](https://bugs.ruby-lang.org/) (_proposed_)
- Features once merged to master but got reverted.

These features are disabled by default, you must opt-in in one of the following ways:

- Add `--edge` or `--proposed` option to `nextify` command when using CLI.
- Enable programmatically when using a runtime mode:

```ruby
# It's important to load language module first
require "ruby-next/language"

require "ruby-next/language/rewriters/edge"
# or
require "ruby-next/language/rewriters/proposed"

# and then activate the runtime mode
require "ruby-next/language/runtime"
# or require "ruby-next/language/bootsnap"
```

- Set `RUBY_NEXT_EDGE=1` or `RUBY_NEXT_PROPOSED=1` environment variable.

### Supported edge features

- Implicit `it` block parameter ([#19890](https://bugs.ruby-lang.org/issues/18980)).

### Supported proposed features

- _Method reference_ operator (`.:`) ([#13581](https://bugs.ruby-lang.org/issues/13581)).
- Binding non-local variables in pattern matching (`42 => @v`) ([#18408](https://bugs.ruby-lang.org/issues/18408)).

## Custom syntax rewriters

Wonder what would happen if Ruby get a null coalescing operator (`??=`) or some other syntactic feature you want to try out? Ruby Next is here to help you!

Ruby Next allows you to write your own syntax rewriters. Full-featured rewriters (used by Ruby Next itself) operate on AST and usually require parser modifications. However, we also support text-based rewriters which can be used to experiment with new syntax much quicker without dealing with grammars, parsers and syntax trees.

> [!TIP]
> You can experiment with Ruby Next rewriters at our [online playground][playground]!

To implement a text-based rewriter, you need to create a new class inherited from `RubyNext::Language::Rewriters::Text` and implementing either `#rewrite` or `#safe_rewrite` method. For example, the method reference operator (`.:`) could be implemented as follows:

```ruby
class MethodReferenceRewriter < RubyNext::Language::Rewriters::Text
  # Rewriter configuration includes its name, a syntax probe and a minimum supported Ruby version.
  # The latter two are used to determine whether the rewriter should be activated for the current file in runtime or when running `ruby-next nextify`.
  NAME = "method-reference"
  SYNTAX_PROBE = "Language.:transform"
  MIN_SUPPORTED_VERSION = Gem::Version.new(RubyNext::NEXT_VERSION)

  def safe_rewrite(source)
    source.gsub(/\.:([\w_]+)/, '.method(:\1)')
  end
end

# Add the rewriter to the list of rewriters
RubyNext::Language.rewriters << MethodReferenceRewriter
```

The `#safe_rewrite` method operates on the normalized source code (i.e., without comments and string literals). It's useful when you want to avoid transpiling inside strings or comments. If you want to transpile the original contents, you can use the `#rewrite` method instead. For example, if you want to rewrite comments:

```ruby

class NoteDateRewriter < RubyNext::Language::Rewriters::Text
  NAME = "note-comment-date"
  MIN_SUPPORTED_VERSION = Gem::Version.new(RubyNext::NEXT_VERSION)

  def rewrite(source)
    source.gsub("# NOTE:") do |_match|
      context.track!(self)
      "# NOTE (#{Date.today}):"
    end
  end
end

RubyNext::Language.rewriters << NoteDateRewriter
```

Note that we use the `context` object in the example above. It is responsible for tracking if the rewriter was used for the current file. You must call the `context.track!` method to mark the file as _dirty_ (i.e., it should be transpiled). The input parameter (`source`) is the Ruby source code of the file being transpiled and the output must be the transpiled source code. When using `#safe_rewrite`, marking content as dirty explicitly is not necessary.

### Using parser combinators (Paco)

Under the hood, `#safe_rewrite` uses [Paco][] to parse the source and separate string literals from the rest of the code. You can also leverage [Paco][] in your text rewriters, if you want more control on the parsing process. For better experience, we provide a DSL to define a custom parser and the `#parse` method to use it. Here is an example of implementing the `.:` operator using a Paco parser:

```ruby
class MethodReferenceRewriter < RubyNext::Language::Rewriters::Text
  NAME = "method-reference"
  SYNTAX_PROBE = "Language.:transform"

  parser do
    def default
      many(
        alt(
          method_ref,
          any_char
        )
      )
    end

    def method_ref
      seq(
        string(".:").result(""),
        method_name
      # IMPORTANT: Use `#track!` method to mark the file as dirty
      ).fmap { track! }.fmap { ".method(:#{_1})" }
    end

    def method_name = regexp(/[\w_]+/)
  end

  def safe_rewrite(source)
    parse(source).join
  end
end

# Add the rewriter to the list of rewriters
RubyNext::Language.rewriters << MethodReferenceRewriter
```

When using the `ruby-next nextify` command, you can load custom rewriters via the `--import-rewriter` option.

## Known limitations

Ruby Next aims to be _reasonably compatible_ with MRI. That means, some edge cases could be uncovered. Below is the list of known limitations.

For gem authors, we recommend testing against all supported versions on CI to make sure you're not hit by edge cases.

### Enumerable methods

Using refinements (`using RubyNext`) for modules could lead to unexpected behaviour in case there is also a `prepend` for the same module in Ruby <2.7.
To eliminate this, we also refine Array (when appropriate), but other enumerables could be affected.

See [this issue](https://bugs.ruby-lang.org/issues/13446) for details.

### `Refinement#import_methods`

- Doesn't support importing methods generated with `eval`.
- Doesn't support aliases (both `alias` and `alias_method`).
- In JRuby, importing attribute accessors/readers/writers is not supported.
- When using AST transpiling in runtime, likely fails to import methods from a transpiled files (due to the updated source location).

See the [original PR](https://github.com/ruby-next/ruby-next/pull/85) for more details.

### Other

See [Parser's known issues](https://github.com/whitequark/parser#known-issues).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/ruby-next/ruby-next](ttps://github.com/ruby-next/ruby-next).

See also the [development guide](./DEVELOPMENT.md).

## Acknowledgments

- Thanks to [Jim Gay](https://github.com/saturnflyer) for the original Data polyfill implementation ([polyfill-data](https://github.com/saturnflyer/polyfill-data))

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
[rubocop]: https://github.com/rubocop-hq/rubocop
[backports]: https://github.com/marcandre/backports
[require-hooks]: https://github.com/ruby-next/require-hooks
[Natalie]: https://natalie-lang.org
[Paco]: https://github.com/ruby-next/paco
[playground]: https://ruby-next.github.io
