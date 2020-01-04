# Change log

## master

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
