# Ruby Next Status

## Core

### 2.6

- `Kernel#then` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#then-as-an-alias-for-yield_self))

**NOTE**: technically, we refine `Object` ('cause refining modules [could break](https://bugs.ruby-lang.org/issues/13446))

- `Proc#<<`, `Proc#>>`([ref](https://rubyreferences.github.io/rubychanges/2.6.html#proc-composition))

**NOTE:** we support 2.7 behaviour which is slightly different.

- `Array#union`, `Array#difference` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#arrayunion-and-arraydifference))

- `Enumerable#filter/#filter!` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#hashmerge-with-multiple-arguments))

- (TODO) `String#split` with block ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#stringsplit-with-block))

- `Hash#merge` with multiple args ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#hashmerge-with-multiple-arguments))

### 2.7

- `Enumerable#tally`

- `Array#intersection`

- `Enumerable#filter_map`

- `Enumerator#produce` ([#14781](https://bugs.ruby-lang.org/issues/14781))

- (TODO) `Time#ceil`, `Time#floor`

- (TODO) `UnboundMethod#bind_call`

## Syntax

### 2.6

- Endless ranges (`1..` or `1...`).

**NOTE**: transpiled into `a[1..-1]` for indexes and `(1...Float::INFINITY)` in other cases.

### 2.7

- Pattern matching (`case ... in ... end`) ([#14912](https://bugs.ruby-lang.org/issues/14912))

- One line pattern matching (`1 in a`) ([#15865](https://bugs.ruby-lang.org/issues/15865))

- **REVERTED IN RUBY ([#16275](https://bugs.ruby-lang.org/issues/16275))** Method reference operator (`Module.:method`) ([#12125](https://bugs.ruby-lang.org/issues/12125), [#13581](https://bugs.ruby-lang.org/issues/13581))

You can still use this feature with RubyNext by enabling it explicitly (see [Readme](./README.md)).

- Arguments forwarding (`def a(...) b(...) end`) ([#16253](https://bugs.ruby-lang.org/issues/16253))

- Numbered parameters (`block { _1 }`)

- (TODO) Startless ranges (`..1` or `...1`) ([#14799](https://bugs.ruby-lang.org/issues/14799))
