# Change log

## master

## 0.9.2 (2020-06-24)

- Support passing rewriters to CLI. ([@sl4vr][])

Use `nextify --list-rewriters` to view all available rewriters.
Use `nextify` with `--rewrite=REWRITERS...` option to specify which particular rewriters to use.

## 0.9.1 (2020-06-05)

- Keep `ruby-next` version in sync with `ruby-next-core`. ([@palkan][])

Require `ruby-next-core` of the same version as `ruby-next`.

## 0.9.0 (2020-06-04)

- Add Ruby 2.3 support. ([@palkan][])

- Remove stale transpiled files when running `ruby-next nextify`. ([@palkan][])

- Add Ruby 2.4 support. ([@palkan][])

APIs for <2.5 must be backported via [backports][] gem. Refinements are not supported.

## 0.8.0 (2020-05-01) 🚩

- Add right-hand assignment support. ([@palkan][])

It is real: `13.divmod(5) => a, b`.

- Add endless methods support. ([@palkan][])

Now you can write `def foo() = :bar`.

## 0.7.0 (2020-04-29)

- Try to auto-transpile the source code on load in `.setup_gem_load_path` if transpiled files are missing. ([@palkan][])

This would make it possible to install gems from source if transpiled files do not exist in the repository.

- Use`./.rbnextrc` to define CLI args. ([@palkan][])

You can define CLI options in the configuration file to re-use them between environments or
simply avoid typing every time:

```yml
# .rbnextrc
nextify: |
  --transpiler-mode=rewrite
  --edge
```

- Add `--dry-run` option to CLI. ([@palkan][])

- Raise `SyntaxError` when parsing fails. ([@palkan][])

Previously, we let Parser to raise its `Parser::SyntaxError` but some exceptions
are not reported by Parser and should be handled by transpiler (and we raised `SyntaxError` in that case, as MRI does).

This change unifies the exceptions raised during transpiling.

## 0.6.0 (2020-04-23)

- Changed the way edge/proposed features are activated. ([@palkan][])

Use `--edge` or `--proposed` flags for `ruby-next nextify` or
`require "ruby-next/language/{edge,proposed}"` in your code.

See more in the [Readme](./README.md#proposed-and-edge-features).

- Updated RuboCop integration. ([@palkan][])

Make sure you use `TargetRubyVersion: next` in your RuboCop configuration.

- Upgraded to `ruby-next-parser` for edge features. ([@palkan][])

It's no longer needed to use Parser gem from Ruby Next package registry.

## 0.5.3 (2020-03-25)

- Enhance logging. ([@palkan][])

Use `RUBY_NEXT_WARN=false` to disable warnings.
Use `RUBY_NEXT_DEBUG=path.rb` to display the transpiler output only for matching files
in the runtime mode.

## 0.5.1 (2020-03-20)

- Add RuboCop integration. ([@palkan][])

Adds support for missing node types and fixes some bugs with 2.7.

## 0.5.0 (2020-03-20)

- Add `rewrite` transpiler mode. ([@palkan][])

Add support for rewriting the source code instead of rebuilding it from scratch to
preserve the original layout and improve the debugging experience.

## 0.4.0 (2020-03-09)

- Optimize pattern matching transpiled code. ([@palkan][])

For array patterns, transpiled code is ~1.5-2x faster than native.
For hash patterns it's about the same.

- Pattern matching is 100% compatible with RubySpec. ([@palkan][])

- Add `Symbol#start_with?/end_with?`. ([@palkan][])

## 0.3.0 (2020-02-14) 💕

- Add `Time#floor` and `Time#ceil`. ([@palkan][])

- Add `UnboundMethod#bind_call`. ([@palkan][])

- Add `String#split` with block. ([@palkan][])

- **Check for _native_ method implementation to activate a refinement.** ([@palkan][])

Add a method refinement to `using RubyNext` even if the backport is present. That
helps to avoid the conflicts with invalid monkey-patches.

- Add `ruby-next core_ext` command. ([@palkan][])

This command allows generating custom core extension files. Meant to be used in
alternative Ruby implementations (mruby, Opal, etc.) not compatible with the `ruby-next-core` gem.

- Add `ruby-next/core_ext`. ([@palkan][])

Now you can use core extensions (monkey-patches) instead of the refinements.

- Check whether pattern matching target respond to `#deconstruct` / `#deconstruct_keys`. ([@palkan][])

- Fix `Struct#deconstruct_keys` to respect passed keys. ([@palkan][])

## 0.2.0 (2020-01-13) 🎄

- Add `Enumerator.produce`. ([@palkan][])

- Add Bootsnap integration. ([@palkan][])

Add `require "ruby-next/language/bootsnap"` after setting up Bootsnap
to transpile the files on load (and cache the resulted iseq via Bootsnap as usually).

- Do not patch `eval` and friends when using runtime mode. ([@palkan][])

Eval support should  be enabled explicitly via the `RubyNext::Language::Eval` refinement, 'cause we cannot handle all the edge cases easily (e.g., the usage caller's binding locals).

- Revoke method reference support. ([@palkan][])

You can still use this feature by enabling it explicitly (see Readme).

- Support in modifier. ([@palkan][])

```ruby
{a: 1, b: 2} in {a:, **}
p a #=> 1
```

## 0.1.0 (2019-11-18)

- Support hash pattern in array and vice versa. ([@palkan][])

- Handle multiple `-e` in `uby-next`. ([@palkan][])

## 0.1.0 (2019-11-16)

- Add pattern matching. ([@palkan][])

- Add numbered parameters. ([@palkan][])

- Add arguments forwarding. ([@palkan][])

- Add `Enumerable#filter_map`. ([@palkan][])

- Add `Enumerable#filter/filter!`. ([@palkan][])

- Add multiple arguments support to `Hash#merge`. ([@palkan][])

- Add `Array#intersection`, `Array#union`, `Array#difference`. ([@palkan][])

- Add `Enumerable#tally`. ([@palkan][])

- Implement gem integration flow. ([@palkan][])

  - Transpile code via `ruby-next nextify`.
  - Setup load path via `RubyNext::Language.setup_gem_load_Path`.

- Add `ruby-next nextify` command. ([@palkan][])

- Add endless Range support. ([@palkan][])

- Add method reference syntax support. ([@palkan][])

- Add `Proc#<<` and `Proc#>>`. ([@palkan][])

- Add `Kernel#then`. ([@palkan][])

[@palkan]: https://github.com/palkan
[backports]: https://github.com/marcandre/backports
[@sl4vr]: https://github.com/sl4vr
