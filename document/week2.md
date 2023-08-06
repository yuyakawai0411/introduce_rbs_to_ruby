# ruby に型を導入する意義

## 目次

1. ruby が提供する型解析機能
   1. 型システムの種類
   2. 型の互換性を判断する手法
   3. ライブラリ群
2. rbs の型注釈
   1. 型の付け方
   2. 使用できる型
   3.

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

#### 名前的部分型

その型の定義が同じであれば互換性があると考える手法。そのため、ある型が別の型のサブタイプであることを明示的に宣言しなければならない。

### ライブラリ群

型注釈は rbs、型推論は TypeProf、 型検査は steep が担う。

#### typescript が提供する型推論との違い

TypeProf は ruby コードから型推論を行い、rbs ファイルを生成するライブラリである。そのため、typescript のような型推論の結果を型検査にしようするようなことはできない。

## rbs の型注釈

### 型の付け方

#### プロパティ

```ruby
# 定数
class PersonalInformation
   GENDER: Array[String]
end

# インスタンス変数
class PersonalInformation
  @name: String
  @age: Integer
end
```

#### メソッド

`def メソッド名: (引数の型) -> 戻り値の型`で書く。その他以下のルールがある。

- メソッドは、class や module の中でしか定義できない
- クラスメソッドでは、`class << self`の記法は使えず、`self.`で定義する

```ruby
class Sample
   # クラスメソッド
   def self.foo: (Integer) -> String
   # インスタンスメソッド
   def foo: (Integer, Integer) -> String
   # 可変長の引数を受け取るとき
   def foo: (*Integer) -> String
   # キーワード引数を受け取るとき
   def foo: (n: Integer) -> String
   # ブロックを受け取るとき
   def foo: () { (Integer) -> void } -> String
   # 引数がオプショナルな場合
   def foo: (?Integer) -> String
   def foo: (?n: Integer) -> String
   def foo: () ?{ (Integer) -> void } -> String
   # attr_*
   attr_reader foo: Integer
end
```

### 提供されている型

#### self

```ruby
class Sample
   # Sampleのインスタンスが返る rubyのselfと同じ挙動
  def foo: () -> self
end
```

####

### 型を自作する
