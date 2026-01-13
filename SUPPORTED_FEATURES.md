# Ruby Next Status

## Language

### Proposals

- **REVERTED IN RUBY ([#16275](https://bugs.ruby-lang.org/issues/16275))** Method reference operator (`Module.:method`) ([#12125](https://bugs.ruby-lang.org/issues/12125), [#13581](https://bugs.ruby-lang.org/issues/13581))

- Binding instance, class, global variables in pattern matching (`42 => @v`) ([#18408](https://bugs.ruby-lang.org/issues/18408)) (**REJECTED**, [see comment](https://bugs.ruby-lang.org/issues/18408#note-19)).

### 3.4

- Implicit `it` block parameter ([#19890](https://bugs.ruby-lang.org/issues/18980)).

### 3.2

- Anonymous rest and keyword rest arguments forwarding (`def foo(*, **); bar(*, **) end`) ([#5148](https://github.com/ruby/ruby/pull/5148))

### 3.1

- Shorthand Hash/kwarg notation (`data = {x:, y:}` or `foo(x:, y:)`) ([#15236](https://bugs.ruby-lang.org/issues/15236)).

- Pinning instance, class and global variables and expressions ([#17724](https://bugs.ruby-lang.org/issues/17724), [#17411](https://bugs.ruby-lang.org/issues/17411)).

- Anonymous blocks `def b(&); c(&); end` ([#11256](https://bugs.ruby-lang.org/issues/11256)).

- Command syntax in endless methods (`def foo() = puts "bar"`) ([#17398](https://bugs.ruby-lang.org/issues/17398))

### 3.0

- "Endless" method definition (`def foo() = 42`) ([#16746](https://bugs.ruby-lang.org/issues/16746))

- Find pattern (`[0, 1, 2] in [*, 1 => a, *c]`) ([#16828](https://bugs.ruby-lang.org/issues/16828)).

- Single-line pattern matching (`{a: 2} in {a:, b:}` or `{a: 2} => {a:, b:}`)

### 2.7

- Pattern matching (`case ... in ... end`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#pattern-matching))

- Arguments forwarding (`def a(...) b(...); end` and `def a(...) b(1, ...); end`) ([#16253](https://bugs.ruby-lang.org/issues/16253), [#16378](https://bugs.ruby-lang.org/issues/16378))

- Numbered parameters (`block { _1 }`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#numbered-block-parameters))

- (_WONTFIX_) Startless ranges (`..1` or `...1`) ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#beginless-range))

The possible translation depends on the _end_ type which could hardly be inferred from the source code.

### 2.6

- Endless ranges (`1..` or `1...`) ([ref](https://rubyreferences.github.io/rubychanges/2.6.html#endless-range-1))

**NOTE**: transpiled into `a[1..-1]` for indexes and `(1...Float::INFINITY)` in other cases.

### 2.5

- do/end blocks work with ensure/rescue/else ([#12906](https://bugs.ruby-lang.org/issues/12906))

## Core APIs

### 4.0

- `Array#rfind` ([#21678](https://bugs.ruby-lang.org/issues/21678))

- `Enumerator.produce(*, size:, &)` ([#21701](https://bugs.ruby-lang.org/issues/21701))

- `String#strip`, `#lstrip`, `#rstrip` (and `!` variants) with character selectors ([#21552](https://bugs.ruby-lang.org/issues/21552))

### 3.3

- `MatchData#named_captures(symbolize_names: true)` ([#19591](https://bugs.ruby-lang.org/issues/19591))

### 3.2

- `Data` class. ([#16122](https://bugs.ruby-lang.org/issues/16122))

- `MatchData#{deconstruct,deconstruct_keys}` ([#18821](https://bugs.ruby-lang.org/issues/18821))

- `Time#deconstruct_keys` ([#19071](https://bugs.ruby-lang.org/issues/19071))

### 3.1

- `Array#intersect?` ([#15198](https://bugs.ruby-lang.org/issues/15198))

- `Enumerable#tally` with the resulting hash ([#17744](https://bugs.ruby-lang.org/issues/17744))

- `Refinement#import_methods` ([#17429](https://bugs.ruby-lang.org/issues/17429)). **NOTE:** The polyfill+transpiling only works for Ruby 2.7+; for older versions consider using `#include` instead.

- `MatchData#match` ([#18172](https://bugs.ruby-lang.org/issues/18172))

- `Enumerable#compact`, `Enumerator::Lazy#compact` ([#17312](https://bugs.ruby-lang.org/issues/17312))

- `Integer.try_convert` ([#15211](https://bugs.ruby-lang.org/issues/15211))

### 3.0

- `Hash#except` ([#15822](https://bugs.ruby-lang.org/issues/15822))

### 2.7

- `Enumerable#tally` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumerabletally))

- `Array#intersection` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#arrayintersection))

- `Enumerable#filter_map` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumerablefilter_map))

- `Enumerator#produce` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#enumeratorproduce))

- `Time#ceil`, `Time#floor` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#floor-and-ceil))

- `UnboundMethod#bind_call` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#unboundmethodbind_call))

- `Symbol#start_with?`, `Symbol#end_with?` ([ref](https://rubyreferences.github.io/rubychanges/2.7.html#symbolstart_with-and-end_with))

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
