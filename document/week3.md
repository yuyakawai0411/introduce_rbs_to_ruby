# rbs で型注釈を書く

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

class は命名的部分型として扱われる。<br>
継承関係は、`class クラス名 < スーパークラス名`で表すことができる。<br>
ruby の class と同様に、class 内では変数,定数,mixin,メソッドの宣言をすることができる。<br>

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

module は構造的部分型として扱われる。<br>
module 内の self の型を制限(mixin 先を制限)は、 `module モジュール名 : クラス名, モジュール名, インターフェース名`で実現できる。<br>
ruby の module と同様に、module 内では定数,mixin,メソッドの宣言をすることができる<br>

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
  include Put
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
  include Bar
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

interface は構造的部分型として扱われる。<br>
interface は`interface _インターフェース名`のようにインターフェース名にアンダーバーをつける必要がある。<br>
interface では、mixin,メソッドだけ宣言することができる<br>

```ruby
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

## ruby
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

型に別名をつけることができる。<br>
typescript のように関数型を type に格納することはできない。(メソッドの定義まで含めないと関数型として機能しない)<br>

```ruby
### typescript
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

mixin を宣言することができる。<br>
interface では、interface しか mixin することができない<br>

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

クラスメソッドやインスタンスメソッドは以下のように定義することができる。private も定義することができる。

```ruby
class Sample
   # インスタンスメソッドとクラスメソッドを定義する例
   ## クラスメソッドでは、`class << self`の記法は使えず、`self.`で定義する

   # privateも定義できる例, privateを呼び出そうとしてエラーになる例
end
```

#### ダックタイピング

```ruby
# ダックタイピングを許容している例, interfaceを使用する

```

#### 動的メソッド

@dynamic を使って、メソッドがあることを明示的にしめすことができる

```ruby
## attr_readerを許容している例

## define_methodを許容している例

## aliasを許容している例
```

#### オーバーロード

同じクラス内で同じメソッドを定義することができる

```ruby
## オーバーロードの例
```

## まとめ

- rbs では、型情報と定義(def, class)を組み合わせて、型チェックを行なっているように思えた。
  - typescript には、定義という部分が存在しない
- ruby で作成した小さいプログラムに対して型情報を付与するのであれば、rbs と steep で不自由なくできる気がした。
  - 残念ながら raise のスローを確認する型はない
  - rails でこれをやるとなると結構大変そう
