## rbs 型注釈

### プロパティ

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

### メソッド

`def メソッド名: (引数の型) -> 戻り値の型`で書く。その他以下のルールがある。

- メソッドは、class や module の中でしか定義できない
- クラスメソッドでは、`class << self`の記法は使えず、`self.`で定義する

```ruby
class Sample
   # クラスメソッド
   def self.foo: (Integer) -> String
   # インスタンスメソッド
   # 引数名を記述した方がわかりやすそう
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

type エイリアス
type result = String | Symbol

class Sample
def sample: () -> result
end

# 名前空間を使う時

module Response
type result = String | Symbol
end

class Sample
def sample: () -> Response::result
end
