# アプリケーションに RBS を導入する

## 目次

1. アプリケーションに型を導入する流れ
2. 外部ライブラリの型情報を生成する
3. 自作コードの型情報を生成する

## アプリケーションに型を導入する流れ

1. 外部ライブラリの型情報を生成する
   1. 外部ライブラリの型情報をインストール
   2. rails の型情報を追加で生成する
   3. 型検査を実行する
2. 自作コードの型情報を生成する
   1. 自動生成
   2. 手動修正
   3. 型検査を実行する

## 外部ライブラリの型情報を生成する

rails の型情報を生成することを例に考えます。以下のライブラリを事前に bundle install しています。

- rails
- rbs_rails
- steep

### 外部ライブラリの型情報をインストール

#### 1. 以下のコマンドを実行して、`rbs_collection.yaml`を生成する。

```terminal
# rbs gemが提供しているコマンド
$rbs collection init
```

#### 2. 以下のコマンドを実行して、外部ライブラリの型情報をインストールする。

```terminal
$rbs collection install
```

#### rbs_collection.yaml とは？

ライブラリのバージョンごとに RBS ファイルを管理するためのファイル(ライブラリのバージョン毎に RBS ファイルが異なるため)。<br>

```yaml
# rbs_collection.yaml
sources:
  - name: ruby/gem_rbs_collection
    remote: https://github.com/ruby/gem_rbs_collection.git
    revision: main
    repo_dir: gems

path: .gem_rbs_collection

# Gemfile.lockから取得できなかったライブラリやRBSファイルをインストールする必要がないライブラリを定義する
gems:
  - name: rbs
    ignore: true # ignoreするとRBSファイルを取得しない
  - name: steep
    ignore: true
```

#### 外部ライブラリの型情報はどのようにしてインストールされているのか？

Gemfile.lock に記載されている外部ライブラリを[gem_rbs_collection](https://github.com/ruby/gem_rbs_collection/tree/main/gems)リポジトリからインストールしている。<br>
上記のコマンドを実行した後は、`rbs_collection.lock.yaml`と.gem_rbs_collection ディレクトリ下に RBS ファイルが作成されている。

```yaml
# rbs_collection.lock.yaml
sources:
  - type: git
    name: ruby/gem_rbs_collection
    revision: 267dd270bb5aabcc1e21c87f44360f0680a8501c
    remote: https://github.com/ruby/gem_rbs_collection.git
    repo_dir: gems
path: ".gem_rbs_collection"
gems:
  - name: activemodel
    version: "7.0"
    source:
      type: git
      name: ruby/gem_rbs_collection
      revision: 267dd270bb5aabcc1e21c87f44360f0680a8501c
      remote: https://github.com/ruby/gem_rbs_collection.git
      repo_dir: gems
---
gemfile_lock_path: Gemfile.lock
```

[参考文献](https://github.com/ruby/rbs/blob/master/docs/collection.md)

### rails の型情報を追加で生成する

#### 1. 以下のコマンドを実行して、`lib/tasks/rbs.rake`を生成する。

```terminal
# rbs_rails gemが提供しているコマンド
rails g rbs_rails:install
```

```ruby
# lib/tasks/rbs.rake
require 'rbs_rails/rake_task'

RbsRails::RakeTask.new
```

#### 2. 以下のコマンドで rake タスクを実行し、RBS ファイルを生成する。

```terminal
rake rbs_rails:all
```

#### rake タスクでどのような RBS ファイルが生成されるのか？

rails が自動的に生成する ActiveRecord モデルの型情報が作成される。(自分で ActiveRecord モデルに実装したコードの型情報は生成されない)<br>
例えば、`$rails g scaffold todo title:string`で自動生成されたアプリケーションだと以下のような型情報が sig/rbs_rails ディレクトリ下に生成される。

```ruby
# todo.rbs
class Todo < ::ApplicationRecord
  extend _ActiveRecord_Relation_ClassMethods[Todo, ActiveRecord_Relation, Integer]

  module GeneratedAttributeMethods
    def title: () -> String?

    def title=: (String?) -> String?

    def title?: () -> bool

    def title_changed?: () -> bool

    def title_change: () -> [ String?, String? ]
  ...
  class ActiveRecord_Relation < ::ActiveRecord::Relation
    include GeneratedRelationMethods
    include _ActiveRecord_Relation[Todo, Integer]
    include Enumerable[Todo]
  end
end
```

[参考文献](https://github.com/pocke/rbs_rails)

### 型検査を実行する

#### 1. Steepfile を編集する

```ruby
D = Steep::Diagnostic

target :app do
  signature "sig" # sig以下の指定で問題ないか？ ./gem_rbs_collection以下の型情報を読んでくれるか？

  check "app" # appディレクトリを型検査の対象とする

  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnknownConstant] = :information
  end
end
```

#### 2. 以下のコマンドを実行して、型検査をする。

```terminal
# steep gemが提供しているコマンド
steep check
```

#### 型検査でエラーになる

基本的に controller 系の型情報が提供されていなかったりするため、`$rails g scaffold todo title:string`したままの状態だと型エラーになります。(ActiveRecord 周りは型情報があるため型エラーにならない)<br>
型情報を自分で追加したり、型検査の対象とするディレクトリを制限する必要があります。

## 自作コードの型情報を生成する

### 自動生成

自動生成するコマンドは以下の 3 つがある。<br>
動的解析では、実際にコードを動かして解析するため、エントリポイントとなるファイルを渡す必要がある。
| コマンド | rbs prototype rb | rbs prototype runtime | typeprof |
| --- |---|---|---|
| 型解析 | 静的解析 | 動的解析 | 動的解析 |
| ファイル形式 | rb | rb | rb, rbs |
| ライブラリ | rbs | rbs | ruby |

[参考文献](https://pocke.hatenablog.com/entry/2020/12/18/230235)

#### rbs prototype rb

#### rbs prototype runtime

#### typeprof

### 手動修正

以下の勉強会でやったように、手動で型注釈を追加していく。<br>
[rbs で型注釈を書く](document/week3.md)

## まとめ

- 型検査の範囲について
  - steep の check の範囲を狭めて、どんどん拡大する方針で進めた方がいいと思った。
  - まずは rails の実装に左右されない、Amateras モデルや Form オブジェクトなど
- 型情報の自動生成について
  - コードを動かさないとわからないメソッド(rails, 動的メソッド)があるなら、rbs prototype runtime、なければ rbs prototype rb
  - 一度にまとめて生成せず、必要なファイルのみに絞って生成すること
  - 自動生成した後、手動で確認する必要があること
