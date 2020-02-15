# Change log

## master

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
{a:1, b: 2} in {a:, **}
p a #=> 1
```

## 0.1.0 (2019-11-18)

- Support hash pattern in array and vice versa. ([@palkan][])

- Handle multile `-e` in `uby-next`. ([@palkan][])

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
