# Ruby Next Status

## Core

### 2.6

- `Kernel#then` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#then-as-an-alias-for-yield_self))

**NOTE**: technically, we refine `Object` ('cause refining modules [could break](https://bugs.ruby-lang.org/issues/13446))

- `Proc#<<`, `Proc#>>`([ref](https://rubyreferences.github.io/rubychanges/2.6.html#proc-composition))

**NOTE:** we support 2.7 behaviour which is slightly different.

- `Array#union`, `Array#difference` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#arrayunion-and-arraydifference))

- `Enumerable#filter/#filter!` ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#hashmerge-with-multiple-arguments))

- `String#split` with block ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#stringsplit-with-block))

**NOTE:** the implementation is very-straightforward and uses and intermediate array; it's only added to provide an API, not the optimization itself.

- `Hash#merge` with multiple args ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#hashmerge-with-multiple-arguments))

### 2.7

- `Enumerable#tally` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumerabletally))

- `Array#intersection` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#arrayintersection))

- `Enumerable#filter_map` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumerablefilter_map))

- `Enumerator#produce` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumeratorproduce))

- `Time#ceil`, `Time#floor` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#floor-and-ceil))

- `UnboundMethod#bind_call` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#unboundmethodbind_call))

- `Symbol#start_with?`, `Symbol#end_with?` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#symbolstart_with-and-end_with))

### 3.0

- `Hash#except` ([#15822](https://bugs.ruby-lang.org/issues/15822))

## Syntax

### 2.6

- Endless ranges (`1..` or `1...`) ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#endless-range-1))

**NOTE**: transpiled into `a[1..-1]` for indexes and `(1...Float::INFINITY)` in other cases.

### 2.7

- Pattern matching (`case ... in ... end`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#pattern-matching))

- Arguments forwarding (`def a(...) b(...); end` and `def a(...) b(1, ...); end`) ([#16253](https://bugs.ruby-lang.org/issues/16253), [#16378](https://bugs.ruby-lang.org/issues/16378))

- Numbered parameters (`block { _1 }`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#numbered-block-parameters))

- (_WONTFIX_) Startless ranges (`..1` or `...1`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#beginless-range))

The possible translation depends on the _end_ type which could hardly be inferred from the source code.

### 3.0

- "Endless" method definition (`def foo() = 42`) ([#16746](https://bugs.ruby-lang.org/issues/16746))

- Right-hand assignment (`13.divmod(5) => a,b`) ([#15921](https://bugs.ruby-lang.org/issues/15921))

- Find pattern (`[0, 1, 2] in [*, 1 => a, *c]`) ([#16828](https://bugs.ruby-lang.org/issues/16828)).

### Proposals

- **REVERTED IN RUBY ([#16275](https://bugs.ruby-lang.org/issues/16275))** Method reference operator (`Module.:method`) ([#12125](https://bugs.ruby-lang.org/issues/12125), [#13581](https://bugs.ruby-lang.org/issues/13581))

- Shorthand Hash notation (`data = {x, y}`) ([#15236](https://bugs.ruby-lang.org/issues/15236)).
