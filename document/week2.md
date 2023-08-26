# ruby が提供する型解析機能

## 目次

1. 型解析機能
   1. 型システムの種類
   2. 型の互換性を判断する手法
   3. ライブラリ群
2. 型の種類
   1. 基本型
   2. リテラル型
   3. 複合型
   4. レコード型
3. 型引数
   1. 基本
   2. 制約
   3. 共変性・反変性
4. まとめ

## 型解析機能

### 型システムの種類

漸進的型付けに位置する。漸進的型付けとは、静的型付けや動的型付けの中間的存在で、typescript も漸進的型付けの一種である。<br>
主に以下のような特徴を持つ。

- 型注釈(アノテーション)はプログラムの実行に影響を及ぼさない
- コンパイル時に型検査を行う
- 部分的に型検査を行う(型注釈があるもの、any 型でないものを型検査する)

### 型の互換性を判断する手法

構造的部分型と名前的部分型を使い分けている。typescript は構造的部分型を採用しているが、rbs は型をクラス名で指定した時は名前的部分型、それ以外は構造的部分型を採用している。

#### 構造的部分型

その型が持っているプロパティやメソッドが同じであれば互換性があると考える手法。そのため、ある型が別の型のサブタイプであるこを明示的に宣言する必要がない。

```typescript
type Cat = { name: string };
type Dog = { name: string };

function cry(animal: Cat) {
  console.log(`My name is... ${animal.name}!`);
}

const dog: Dog = { name: "Pochi" };

cry(dog);
 => 型エラーにならない
```

#### 名前的部分型

その型の定義が同じであれば互換性があると考える手法。そのため、ある型が別の型のサブタイプであることを明示的に宣言しなければならない。<br>
**ex1. サブタイプであることを宣言しない**

```ruby
## rbs
class Cat
  attr_reader name: String

  def initialize: (String) -> void
end

class Dog
  attr_reader name: String

  def initialize: (String) -> void
end

class Object
  def cry: (Cat) -> void
end

## ruby(クラスやメソッドの定義は省略)
dog = Dog.new("Pochi")
cry(dog)

## ターミナル
$ steep check
 => Cannot pass a value of type `::Dog` as an argument of type `::Cat`
```

**ex2. サブタイプであることをクラスの継承によって明示的に宣言**

```ruby
## rbs
class Animal
  attr_reader name: String

  def initialize: (String) -> void
end

class Cat < Animal
end

class Dog < Animal
end

class Object
  def cry: (Animal) -> void
end

## ruby(クラスやメソッドの定義は省略)
dog = Dog.new("Pochi")
cry(dog)

## ターミナル
$ steep check
 => No type error detected.
```

### ライブラリ群

型注釈は rbs、型検査は steep、型推論は TypeProf が担う。<br>

#### steep で型検査を始める

```terminal
$ steep check
```

#### TypeProf で型推論を始める

TypeProf は ruby コードから型推論を行い、rbs コードの生成を行うライブラリ。そのため、typescript のように型検査中に型推論を行うようなことはできない。

```
$ typeprof -v lib/sample.rb
 => 以下のようなrbsコードが出力される

# Classes
class Animal
  attr_reader name: untyped
  def initialize: (untyped name) -> void
end
```

**ex3. typescript では return の型をかかなくとも、型推論で型エラーになる**

```typescript
function give(){
  return { value: 'string' };
}

function receive(arg: number) {
  console.log(arg.value);
}

const result = give();

receive(result);
 => 型 '{ value: string; }' の引数を型 'number' のパラメーターに割り当てることはできません。
```

## 型の種類

### 基本型

instance 型は ruby の標準ライブラリや、自作のインスタンスをクラス名で参照でき、最もよく使うと思われる

```ruby
class Sample
   # instance型(ex. String, Integer)
   def sample_instance() -> String
   # nil型
   def sample_nil() -> nil
   # any型
   def sample_untyped() -> untyped
   # self型
   def sample_self() -> self
   # bool型
   def sample_self() -> bool
   # void型
   def sample_void() -> void
end
```

### リテラル型

特定の値だけを代入可能にする型

```ruby
class Sample
  # 文字列のリテラル
  def sample_string: () -> "x"

  # シンボルのリテラル
  def sample_symbol: () -> :x

  # 数値のリテラル
  def sample_integer: () -> 42
end
```

### 複合型

複数の型を連結した型

```ruby
class Sample
  # オプショナル
  def sample_optional: (String?) -> void

  # ユニオン型(和集合)
  def sample_union: (String | Integer) -> void

  # インターセクション型(積集合)
  def sample_intersection: (_Foo & _Bar) -> void
end
```

**ex4. インターセクション型の使用例**

対象のオブジェクトが、指定したメソッドを全て持っているかを確認する。<br>
[インターセクション型はなぜ積集合という命名なのか？](https://qiita.com/ist-ko-su/items/af8224f7571817fbb9bd)

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

class BarInheritsFromFoo < Foo
  include _Bar
end

class FooBar
  include _Foo
  include _Bar
end

class Object
  def put_foo_bar: (_Foo & _Bar) -> void
end

## ruby
class Foo
  def foo
    "foo"
  end
end

class BarInheritsFromFoo < Foo
  def bar
    "bar"
  end
end

class FooBar
  def foo
    "foo"
  end

  def bar
    "bar"
  end
end

def put_foo_bar(object)
  puts object.foo
  puts object.bar
end

## ターミナル
put_foo_bar(Foo.new)
 => Cannot pass a value of type `::Foo` as an argument of type `(::_Foo & ::_Bar)`
put_foo_bar(BarInheritsFromFoo.new)
 => No type error detected.
put_foo_bar(FooBar.new)
 => No type error detected.
```

### レコード型

キーバリューのデータを格納する型<br>
[steep で Hash(Symbol, String)として扱われてしまい、レコード型の型検査が上手くできない？](https://github.com/yuyakawai0411/introduce_rbs_to_ruby/issues/10)

```ruby
class Sample
  def sample: () -> { x: String, y: Integer }

  # ネストした場合
  def sample_nest: () -> { x: { a: Integer, b: Integer } }

  # keyが動的な場合は、instance型のHashを使う
  def sample_hash: () -> Hash[Symbol, String]
end
```

## 型引数

### 基本

型の安全性とコードの共通化を両立するため、具体的な型を指定せず、引数で型を指定する方法

```ruby
class Array[Elem]
  def first: () -> Elem
end
```

### 制約

型引数に制約を与える。typescript の extends と同じ

```ruby
# Animalクラスもしくはそのサブタイプでなければならない
class Sample[Elem < Animal]
  def cry: () -> Elem
end
```

### 共変性・反変性

共変性・反変性のルールを適用することができる。ruby では型の健全性よりもプロググラムの柔軟性を優先するため、untyped を使用してこれらのるルールを無視することがある。<br>
[共変性・反変性とは?](<https://ja.wikipedia.org/wiki/%E5%85%B1%E5%A4%89%E6%80%A7%E3%81%A8%E5%8F%8D%E5%A4%89%E6%80%A7_(%E8%A8%88%E7%AE%97%E6%A9%9F%E7%A7%91%E5%AD%A6)>)

```ruby
## rbs
class Array[unchecked out Elem]
  def include?: (Elem) -> bool
end

## ターミナル
array_string = ["a", "b", "c"]
# rubyコードとしては動くが、型チェックを通過することができない
array_string << 11
```

#### 共変性(out)

スーパータイプにサブタイプを代入するのを許可する(クラスの継承関係は関係なく代入を許可する)

#### 反変性(in)

サブタイプにスーパータイプを代入するのを許可する。

## まとめ

- ruby が提供する型解析機能は、型注釈は rbs、型推論は TypeProf、 型検査は steep が担う。
  - 型の互換性は、名前的部分型によりクラスの継承を明記することによって判断している
  - 型推論の結果を型検査に適用することはできないため、TypeProf 等を使って自動で rbs ファイルを作成したり、外部ライブラリの rbs ファイルを別途インクルードする必要がある
- typescript,rbs ともに同じような型を似たコードで記述することができるため、型注釈に対する学習コストは少なそう
