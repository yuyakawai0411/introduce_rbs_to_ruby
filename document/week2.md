# ruby に型を導入する意義

## 目次

1. ruby が提供する型解析機能
   1. 型システムの種類
   2. 型の互換性を判断する手法
   3. ライブラリ群
2. rbs 型の種類
   1. 基本型
   2. リテラル型
   3. 複合型
   4. レコード型
   5. ジェネリクス型
3. まとめ

## ruby が提供する型解析機能

### 型システムの種類

漸進的型付けに位置する。漸進的型付けとは、静的型付けや動的型付けの中間的存在で、typescript も漸進的型付けの一種である。<br>
主に以下のような特徴を持つ。

- 型注釈(アノテーション)はプログラムの実行に影響を及ぼさない
- コンパイル時に型検査を行う
- 部分的に型検査を行う(型注釈があるもの、any 型でないものを型検査する)

### 型の互換性を判断する手法

構造的部分型と名前的部分型を使い分けている。typescript は構造的部分型を採用しているが、rbs ではクラスの継承関係に従い、名前的部分型で互換性を検証することが多い。

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

その型の定義が同じであれば互換性があると考える手法。そのため、ある型が別の型のサブタイプであることを明示的に宣言しなければならない。

```ruby
# 型エラーになる例
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
=> Cannot pass a value of type `::Dog` as an argument of type `::Cat`

# 型エラーにならない例
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
=> 型エラーにならない
```

### ライブラリ群

型注釈は rbs、型推論は TypeProf、 型検査は steep が担う。

#### typescript が提供する型推論との違い

TypeProf は ruby コードから型推論を行い、rbs ファイルを生成するライブラリである。そのため、typescript のように型推論の結果を型検査にしようするようなことはできない。

```typescript
function give(){
  return { value: 'string' };
}

function receive(arg: number) {
  console.log(arg.value);
}

const reslut = give();

receive(reslut);
=> 型 '{ value: string; }' の引数を型 'number' のパラメーターに割り当てることはできません。
```

## rbs 型の種類

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
  def sample_optional: () -> String?

  # ユニオン型
  def sample_union: () -> (String | Integer)

  # インターセクション型
  ## Dog,Catに定義されているメソッドを両方持った型
  def sample_intersection: (Dog & Cat) -> void
end
```

### レコード型

キーバリューのデータを格納する型

```ruby
class Sample
  def sample: () -> { x: String, y: Integer }

  # ネストした場合
  def sample_nest: () -> { x: { a: Integer, b: Integer } }

  # keyが動的な場合は、instance型のHashを使う
  def sample_hash: () -> Hash[Symbol, String]
end
```

### ジェネリクス型

型の安全性とコードの共通化を両立するため、型に引数を加えた型

```ruby
class Array[Elem]
  def first: () -> Elem
end

# ジェネリクス型に制限を与える。typescriptのextendsと同じ
class Sample[Elem < Animal]
  def cry: () -> Elem
end

# Arrayのように、様々な型が入るデータ型はuncheckedとoutを組み合わせて定義されている
class Array[unchecked out Elem]
  def include?: (Elem) -> bool
end
https://github.com/ruby/rbs/blob/88b18802aa9e1cc2a2956104b4f3256a55f65577/core/array.rbs#L525
```

#### 共変性(out)

スーパータイプにサブタイプを代入するのを許可する(クラスの継承関係は関係なく代入を許可する)

```ruby
array_string = ["a", "b", "c"]
# rubyコードとしては動くが、型チェックを通過することができない
array_string << 11
```

#### 反変性(in)

サブタイプにスーパータイプを代入するのを許可する。

## まとめ

- ruby が提供する型解析機能は、型注釈は rbs、型推論は TypeProf、 型検査は steep が担う。
  - 型の互換性は、名前的部分型によりクラスの継承を明記することによって判断している
  - 型推論の結果を型検査に適用することはできないため、TypeProf 等を使って自動で rbs ファイルを作成したり、外部ライブラリの rbs ファイルを別途インクルードする必要がある
- typescript,rbs ともに同じような型を似たコードで記述することができるため、型注釈に対する学習コストは少なそう
  - 共変性、反変性という typescript にはない型の概念が存在するが、ruby の柔軟性を維持するために定義されており、我々が普段書くコードではあまり使用しないと思われる
