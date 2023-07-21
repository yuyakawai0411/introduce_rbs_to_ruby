# ruby に型を導入する意義

## 目次

1. 型が存在する意義
   1. プログラムの表現力を上げるため
   2. プログラムが正常に動くことを保証するため
2. ruby に型を導入する意義
   1. rbs
   2. steep

## 型が存在する意義

型が存在する意義は、プログラムの表現力を上げるため、プログラムが正常に動くことを保証するためと考えている。

### プログラムの表現力を上げるため

ソースコードを実行するには、PC が理解できる[バイナリーコード](https://ja.wikipedia.org/wiki/%E3%83%90%E3%82%A4%E3%83%8A%E3%83%AA)へ変換する必要がある。
このバイナリに、現実世界で扱う複雑なデータ(文字、数値 etc)をマッピングするため、型を定義する。<br>
そのため、コンパイラ言語、インタプリタ言語ともに型は定義されている。型は指定子(int, char etc)で、どのように変換するかとサイズの情報を持つ。

[![Image from Gyazo](https://i.gyazo.com/c6eb94c50b19897981437f25a01d95ce.png)](https://gyazo.com/c6eb94c50b19897981437f25a01d95ce)

図 1. ソースコードがバイナリコードに変換される手順(上:コンパイラ言語,下:インタプリタ言語 )

#### 型を付与するタイミング

コンパイラ言語

- ソースコードから直接バイナリーコードに変換するため、ソースコードで型の指定が必要

インタプリタ言語

- ソースコードからバイトコードに変換し、Virtual Machine が型を定義するため、ソースコードで型の指定が不要

#### ruby ではどのような型が付与されているのか?

ruby は、バイトコードを RubyVM のスタックに積み上げていくことで逐次実行している。RubyVM ではバイトコードを C 言語に変換し、実行している。その際に ruby で扱うデータ(オブジェクト)は、VALUE 型として定義されている。

- [RubyVM](https://docs.ruby-lang.org/ja/latest/class/RubyVM.html)
- [VALUE 型](https://docs.ruby-lang.org/en/2.4.0/extension_ja_rdoc.html)

https://qiita.com/south37/items/0eb05ebf31ba6cbf53c4

### プログラムが正常に動くことを保証するため

ソースコードを実行する前に、データ(オブジェクト)に対して不適合な型変換や不正な操作をしていないか検査する。<br>
インタプリタ言語は、動的に型を生成することから、型検査がないものが多く、プログラムが正常に動くことを保証する機能がコンパイラ言語と比べて一部弱い。しかし、動的に型を生成することで、不整合な型変換等を考慮することなくコードが書けるメリットもある。

```c++
## 不適合な型変換でコンパイルエラー
string A = "テスト";
int B = A;
cout << B << endl;
 => cannot convert 'std::__cxx11::string {aka std::__cxx11::basic_string<char>}' to 'int' in initialization

* 型のサイズが違うだけだとコンパイルエラーにならない
int A = 2147483647;
short B = A;
cout << B << endl;
 => -1

## 不正な操作でコンパイルエラー
class Sample
{
public:
  void print()
  {
    printf("テスト");
  }
};

int main()
{
  Sample sample;
  sample.printf();
  return 0;
}
 => 'class Sample' has no member named 'printf'; did you mean 'print'?
```

図 2. コンパイラ言語の型検査

#### ruby は型のサイズも動的に決まる

ruby の integer は、[Fixnum クラスと Bignum クラス](https://scrapbox.io/rubytips/%E6%95%B0%E5%80%A4)で構成されている。
Fixnum は 31 ビットまたは 63 ビットの固定長整数を扱うクラスですが、演算結果をこの範囲を超える場合、自動的に Bignum に拡張される。<br>
https://scrapbox.io/rubytips/%E6%95%B0%E5%80%A4

## ruby に型を導入する意義

インタプリタ言語は、プログラムが正常に動くことを事前に保証する機能がコンパイラ言語と比べて一部弱い。rbs と steep で ruby に型を導入することで、インタプリタ言語のメリットを阻害せず、上記の欠点をカバーすることができる。

### rbs

ruby に型注釈を付与できる言語。<br>
.rb に直接記入するのではなく、.rbs ファイルに記述する。そのため、ruby の機能を阻害するものではない。<br>
https://github.com/ruby/rbs

```ruby
class User
  attr_reader login: String
  attr_reader email: String

  def initialize: (login: String, email: String) -> void
end
```

### steep

.rbs ファイルに対して、静的型検査を行う。<br>
https://github.com/soutaro/steep

```
$ bundle exec steep check
```

## 参考図書

[Ruby の仕組み](https://www.amazon.co.jp/Ruby%E3%81%AE%E3%81%97%E3%81%8F%E3%81%BF-Ruby-Under-Microscope-Shaughnessy/dp/4274050653)
