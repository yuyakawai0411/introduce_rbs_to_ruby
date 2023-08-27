# rbs で型注釈を書く

## 目次

1. Declarations
   1. class
   2. module
   3. interface
   4. type
2. Members
   1. property
   2. method

## Declarations

### class

class を定義し、命名的部分型で型チェックを行うようにすることができる。`<`を使うことで継承関係を明示することができる。<br>

```ruby
## class実装例(継承を含む)


```

### module

module を定義することができる。`:`を使うことで mixin 先の型を限定することができる。<br>

```ruby
## moduleがclassを継承している例

## moduleが別のmoduleを継承している例

## moduleがinterfaceを継承している例
```

### interface

関数型を名前をつけて定義することができる。class や module で参照する場合は、include or extend して宣言した関数型を呼び出すことができる。ジェネリクスを使うことができる

```ruby
## interfaceで定義する例

## interfaceを呼び出す時の例

## ジェネリクスを使える例

```

#### module と interface どちらを使うのか？

```ruby
## moduleとinterfaceの違いを表す例
```

### type

型に別名をつけることができる。名前を指定してそのまま class や module で参照することができる。ジェネリクスを使うことができる

```ruby
## typeで定義する例
type result = String | Symbol
## typeを呼び出す時の例
class Sample
   def sample: () -> result
end
## ジェネリクスを使える例
```

## Members

### プロパティ

定数やインスタンス変数などに型情報を付与することができる

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
# ダックタイピングを許容している例, moduleやinterfaceを使用する

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

## 余力があれば

- raise を表記する例
- 共変性・反変性の例
