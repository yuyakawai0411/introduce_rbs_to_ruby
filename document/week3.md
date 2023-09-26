# RBSで型注釈を書く

## 目次

1. Declarations
   1. class
   2. module
   3. interface
   4. type
   5. constant
2. Members
   1. instance variable
   2. mixin
   3. method

## Declarations

rbs 内で宣言できるものを Declarations という。

### class

`class クラス名 < スーパークラス名`で宣言する。<br>
型を class で指定した場合は、公称型として扱われる。<br>

```ruby
# rbs
class Alphabet
end

class A < Alphabet
end

class Object
  def put_alphabet: (Alphabet) -> void
end

# ruby
class Alphabet
end

class A < Alphabet
end

def put_alphabet(alphabet)
  puts "#{alphabet.class}"
end

alphabet = A.new
put_alphabet(alphabet)

# ターミナル
=> No type error detected.
```

### module

`module モジュール名`で宣言する。<br>
`module モジュール名 : クラス名, モジュール名, インターフェース名`とすることで、mixin を制限できる。<br>

**ex1.クラス名を指定して、mixin を制限する**

```ruby
# rbs
module Put : Alphabet
  def put_alphabet: () -> void
end

class Alphabet
end

class A < Alphabet
  include Put
end

class Sample
  include Put # Alphabetクラス以外にmixinしているためRBS::ModuleSelfTypeError
end

# ruby
module Put
  def put_alphabet
    puts "alphabet"
  end
end

class Alphabet
end

class A < Alphabet
  include Put
end

class Sample
  include Put # Alphabetクラス以外にmixinしているためRBS::ModuleSelfTypeError
end

# ターミナル
=> Module self type constraint in type `::Sample` doesn't satisfy: `::Sample <: ::Alphabet`
```

**ex2.モジュール名を指定して、mixin を制限する**

```ruby
# rbs
module Foo
  def foo: () -> void
end

module Bar : Foo
  def bar: () -> void
end

class FooBar
  include Bar # FooモジュールがmixinされていないためRBS::ModuleSelfTypeError
end

# ruby
module Foo
  def foo
    puts "foo"
  end
end

module Bar
  def bar
    puts "bar"
  end
end

class FooBar
  include Bar # FooモジュールがmixinされていないためRBS::ModuleSelfTypeError
end

# ターミナル
=> Module self type constraint in type `::FooBar` doesn't satisfy: `::FooBar <: ::Foo`
```

### interface

`interface _インターフェース名`で宣言する(アンダーバー必須)。<br>
型を interface で指定した場合は、構造的部分型として扱われる。<br>
interface では、mixin(interface のみ)とメソッドの宣言だけすることができる<br>

```ruby
# rbs
interface _Foo
  def foo: () -> String
end

interface _Bar
  def bar: () -> String
end

class Foo
  include _Foo
end

class FooBar
  include _Foo
  include _Bar
end

class Object
  def put_foo_bar: (_Foo & _Bar) -> void
end

# ruby
module FooModule
  def foo
    "foo"
  end
end

module BarModule
  def bar
    "bar"
  end
end

class Foo
  include FooModule
end

class FooBar
  include FooModule
  include BarModule
end

def put_foo_bar(object)
  puts object.foo
  puts object.bar
end

put_foo_bar(Foo.new) # fooメソッドしか持っていないため型エラー
=> Cannot pass a value of type `::Foo` as an argument of type `(::_Foo & ::_Bar)`
put_foo_bar(FooBar.new) # fooもbarメソッドも持っているためOK
=> No type error detected.
```

### type

`type タイプ名 = 型`で宣言する。<br>
typescript のように関数型を type に格納することはできない。(メソッドの定義まで含めないと関数型として機能しない)<br>

```ruby
# typescript
type result = string | number;

type Increment = (num: number) => number;
const increment: Increment = (num: number): number => num + 1;

# rbs
type result = String | Integer

type Increment = (num: Integer) -> Integer # 関数型をtypeに格納することはできない
class Object
  def increment: Increment
end
```

### constant

定数を宣言できる。<br>
グローバルや class, module 内でも宣言することができる。

```ruby
# rbs
GENDER: Array[String]

class PersonalInformation
   GENDER: Array[String]
end
```

## Members

class, module, interface 内で宣言できるものを Members という

### instance variable

インスタンス変数を宣言することができる。(interface では不可)<br>

```ruby
# rbs
class PersonalInformation
  @name: String
  @age: Integer
  @gender: String
end
```

### mixin

mixin を宣言することができる。(interface では、interface しか mixin することができない)<br>

```ruby
# rbs
module FooModule
  def foo: () -> String
end

class FooBar
  include FooModule
end

interface _Bar
  include FooModule # interfaceではmoduleはmixinできず構文エラー
end
```

### method

メソッドを宣言できる。<br>
`def メソッド名: (引数の型) -> 戻り値の型`が基本的なメソッドの型定義のフォーマットになる<br>
クラスメソッドの定義で使う、class << self の記法は使えない

```ruby
class Sample
   # インスタンスメソッド
   def foo: (Integer, Integer) -> String
   def foo: (?Integer) -> String # 引数がオプショナルな場合

   # クラスメソッド
   def self.foo: (Integer) -> String

   # 可変長の引数を受け取るとき
   def foo: (*Integer) -> String

   # キーワード引数を受け取るとき
   def foo: (n: Integer) -> String
   def foo: (?n: Integer) -> String # 引数がオプショナルな場合

   # ブロックを受け取るとき
   def foo: () { (Integer) -> void } -> String
   def foo: () ?{ (Integer) -> void } -> String # 引数がオプショナルな場合
end
```

#### ダックタイピング

interface を使うことで構造的部分型で判断するようになり、ダックタイピングを実現することができる。

```ruby
## rbs
interface _Foo
  def foo: () -> String
end

interface _Bar
  def bar: () -> String
end

class Foo
  include _Foo
end

class FooBar
  include _Foo
  include _Bar
end

class Object
  def put_foo_bar: (_Foo & _Bar) -> void
end

## ruby(クラスやメソッドの定義は省略)
put_foo_bar(Foo.new) # fooメソッドしか持っていないため型エラー
put_foo_bar(FooBar.new) # foo, barメソッドを持っているためOK

## ターミナル
$ steep check
 => Cannot pass a value of type `::Foo` as an argument of type `(::_Foo & ::_Bar)`

```

#### 動的メソッド

動的メソッド(define_method)に対しては型検査を行うことはできない。<br>
@dynamic アノテーションを使うことで、動的メソッドが実装されていることを Steep に検知させることはできる。これにより`MethodDefinitionMissing`を回避することができる。<br>
[attribute](https://github.com/ruby/rbs/blob/master/docs/syntax.md#attribute-definition)や[alias](https://github.com/ruby/rbs/blob/master/docs/syntax.md#alias)のようなよく使う動的メソッドは、専用の型注釈によって型検査を行うことができる

```ruby
## rbs
class Sample
  def dynamic_method: () -> Integer # 動的メソッドの型検査は行われないため、型エラーにならない
end

## ruby
class Sample
  # @dynamic dynamic_method
  define_method :dynamic_method do
    "dynamic_method"
  end
end

puts Sample.new.dynamic_method

## ターミナル
$ steep check
 => No type error detected. # 動的なメソッドが実装されていることをSteepが検知しているため、MethodDefinitionMissingにはならない
```

## まとめ

- rbs では、型情報と定義(def, class)を組み合わせて、型チェックを行なっているように思えた。
  - typescript には、定義という部分が存在しない
- ruby で作成した小さいプログラムに対して型情報を付与するのであれば、rbs と steep で不自由なくできる気がした。
  - 残念ながら raise のスローを確認する型はない
  - rails でこれをやるとなると結構大変そう
