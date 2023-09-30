# アプリケーションに RBS を導入する

## 目次

1. アプリケーションに型を導入する流れ
2. 外部ライブラリの型情報を生成する
3. 自作コードの型情報を生成する

## アプリケーションに型を導入する流れ

1. 外部ライブラリの型情報を生成する
   1. 外部ライブラリの型情報をインストール
   2. rails の型情報を追加で生成する
2. 自作コードの型情報を生成する
   1. 自動生成
   2. 手動修正
3. 型検査を実行する
   1. 型情報に構文エラーがないかチェックする
   2. 型検査をする

## 外部ライブラリの型情報を生成する

rails の型情報を生成することを例に考えます。以下のライブラリを事前に bundle install しています。

- rails
- rbs_rails
- steep
- typeprof

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

Gemfile.lock に記載されている外部ライブラリを見て[gem_rbs_collection](https://github.com/ruby/gem_rbs_collection/tree/main/gems)リポジトリ(TypeScript で言う DefinitelyTyped)から型情報をインストールしている。<br>
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

ActiveRecord モデルを対象に rails が自動的に生成するメソッドの型情報が作成される。(自作コードや Ruby の動的メソッド等の型情報は生成されない)<br>

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  # 型情報が生成される
  belongs_to :user, optional: true

  # 型情報が生成される
  enum status_type: {
    do: 10,
    doing: 20,
    done: 30,
  }, _prefix: true

  # validatesは型情報が生成されなかった => /.gem_rbs_collectionの方で定義されていた
  validates :title, presence: true
  validates :status_type, presence: true

  # railsが自動生成するメソッドではないため、型情報は作成されない
  define_method :status_type_name do
    CONVERT_TO_STATUS_TYPE[status_type.to_sym].to_s
  end

  # 自身で定義したコードのため、型情報は生成されない
  CONVERT_TO_STATUS_TYPE = {
    do: "実行前",
    doing: "実行中",
    done: "終了",
  }

  # 自身で定義したコードのため、型情報は生成されない
  def title_with_status
    "#{title} (#{CONVERT_TO_STATUS_TYPE[status_type.to_sym]})"
  end
end
```

```ruby
# sig/rbs_rails/app/models/todo.rbs
# 一部のみ抜粋
class Todo < ::ApplicationRecord
  extend _ActiveRecord_Relation_ClassMethods[Todo, ActiveRecord_Relation, Integer]

  # アクセッサ
  module GeneratedAttributeMethods
    def title: () -> String

    def title=: (String) -> String

    def title?: () -> bool

    def status_type=: (String) -> String

    def status_type?: () -> bool
    ...
  end
  include GeneratedAttributeMethods
  ...
  # アソシエーション
  def user: () -> User?
  def user=: (User?) -> User?
  def reload_user: () -> User?
  def build_user: (untyped) -> User
  def create_user: (untyped) -> User
  def create_user!: (untyped) -> User

  # enum
  def status_type_do!: () -> bool
  def status_type_do?: () -> bool
  def status_type_doing!: () -> bool
  def status_type_doing?: () -> bool
  def status_type_done!: () -> bool
  def status_type_done?: () -> bool
end
```

[参考文献](https://github.com/pocke/rbs_rails)

## 自作コードの型情報を生成する

### 自動生成

自動生成するコマンドは以下の 3 つがある。<br>
動的解析では、実際にコードを動かして解析している。(ただし、rbs prototype runtime と typeprof は動かし方のロジックが異なる)
| コマンド | rbs prototype rb | rbs prototype runtime | typeprof |
| --- |---|---|---|
| 型解析 | 静的解析 | 動的解析 | 動的解析 |
| ファイル形式 | rb | rb | rb, rbs |
| ライブラリ | rbs | rbs | typeprof |

[参考文献](https://pocke.hatenablog.com/entry/2020/12/18/230235)

#### rbs prototype rb

`app/models/todo.rb`に対して実行する。<br>
define_method 以外は型情報を正しく生成できている。

```terminal
$rbs prototype rb app/models/todo.rb

class Todo < ApplicationRecord
  CONVERT_TO_STATUS_TYPE: { do: ::String, doing: ::String, done: ::String }

  def title_with_status: () -> ::String
end
```

#### rbs prototype runtime

rails を使用したコードを解析するには以下ように rails のエントリポイントに対して実行する必要がある。<br>
メソッドは網羅されていそうだが、使用しないメソッドの定義が多く含まれてしまうことと、型情報の取得が正常に行えておらず,untyped が多い。

```terminal
$rbs prototype runtime -R config/environment.rb Todo

class Todo < ::ApplicationRecord
  ... rbs_railsと被る箇所のため省略
  public

  def autosave_associated_records_for_user: (*untyped args) -> untyped

  def status_type_name: () -> untyped

  def title_with_status: () -> untyped

  CONVERT_TO_STATUS_TYPE: Hash[untyped, untyped]
end
```

#### typeprof

`app/models/todo.rb`に対して実行する。<br>
型情報を正しく生成できており、define_method も型情報がある。

```terminal
$typeprof app/models/todo.rb

# Classes
class Todo
  CONVERT_TO_STATUS_TYPE: {do: String, doing: String, done: String}

  def status_type_name: -> String
  def title_with_status: -> String
end
```

[参考文献](https://github.com/ruby/typeprof/blob/master/doc/doc.ja.md)

### 手動修正

以下の勉強会でやったように、手動で型注釈を追加していく。<br>
[rbs で型注釈を書く](document/week3.md)

## 型検査を実行する

### 型情報に構文エラーがないかチェックする

#### 1. 以下のコマンドを実行して、構文エラーがないか確認する

```terminal
# rbs gemが提供しているコマンド
rbs validate

Validating class/module definition: `::ActiveModel::Name`...
Validating class/module definition: `::ActiveModel::Naming`...
Validating class/module definition: `::ActiveModel::Railtie`...
Validating class/module definition: `::ActiveModel::SecurePassword`...
Validating class/module definition: `::ActiveModel::SecurePassword::ClassMethods`...
Validating class/module definition: `::ActiveModel::SecurePassword::InstanceMethodsOnActivation`...
Validating class/module definition: `::ActiveModel::Serialization`...
Validating class/module definition: `::ActiveModel::Serializers`...
Validating class/module definition: `::ActiveModel::Serializers::JSON`...
....
```

### 型検査をする

#### 1. Steepfile を編集する

```ruby
target :app do
  check "app" # 型検査の対象とする

  signature "sig" # 型ファイルの参照先
  #.gen_rbs_collectionは指定しなくても読み込んでくれるようになった。それまでは以下のようにlibraryで使用する型を羅列しなければならなかった。(https://speakerdeck.com/pocke/the-newsletter-of-rbs-updates)
  # library 'activesupport'
  # library 'activejob'
  # library 'activemodel'
  # library 'actionview'
  # library 'activerecord'
end
```

#### 2. 以下のコマンドを実行して、型検査をする。

```terminal
# steep gemが提供しているコマンド
steep check
```

#### 型検査でエラーになる

基本的に controller 系の型情報が提供されていなかったりするため、`$rails g scaffold todo title:string`したままの状態でも型エラーになります。(ActiveRecord 周りは型情報があるため型エラーにならない)<br>
型情報を自分で追加したり、型検査の対象とするディレクトリを制限する必要があります。

```terminal
$ steep check

app/controllers/application_controller.rb:1:6: [warning] Cannot find the declaration of class: `ApplicationController`
│ Diagnostic ID: Ruby::UnknownConstant
│
└ class ApplicationController < ActionController::Base
        ~~~~~~~~~~~~~~~~~~~~~

app/controllers/todos_controller.rb:1:6: [warning] Cannot find the declaration of class: `TodosController`
│ Diagnostic ID: Ruby::UnknownConstant
│
└ class TodosController < ApplicationController
        ~~~~~~~~~~~~~~~

app/controllers/todos_controller.rb:1:24: [warning] Cannot find the declaration of class: `ApplicationController`
│ Diagnostic ID: Ruby::UnknownConstant
│
└ class TodosController < ApplicationController
                          ~~~~~~~~~~~~~~~~~~~~~
```

## まとめ

- 外部ライブラリの型情報を生成する
  - 型情報が提供されているライブラリが少ないため、steep で型検証する範囲を狭めて、型情報を追加する度に、検証範囲を拡大する方針がいいと思いました。(もしくは型情報がないところは untyped で型付けする)
  - 例:ライブラリを利用しない実装(amateras モデル,Form オブジェクトなど)→ActiveRecord→ その他
- 自作コードの型情報を生成する
  - typeprof が型情報の自動生成に適していると思いました。
  - 自動生成は、全てのファイルを一度に生成するのではなく、必要なファイルのみ生成する方針がいいと思いました。(ライブラリの型情報に依存しているコードがあると型エラーになるため)
- 外部ライブラリと自作コードの自動生成をしていると型情報か重複することがある。それを解消する rbs subtract というコマンドが新しく rbs gem で提供されることになった
  - https://speakerdeck.com/pocke/lets-write-rbs?slide=8

## 参考文献

- [rbs_collection の導入](https://zenn.dev/leaner_dev/articles/20210915-rubykaigi-2021-rbs-collection)
- [rbs_collection の発表資料](https://docs.google.com/presentation/d/e/2PACX-1vREU6ZguqLxGk_k1l3zvKbRo_TbMTKN3yEgfzrjA85foVXrmeYvWnOTefsaBycsb9m6H924VsZw_YKt/pub?start=false&loop=false&delayms=3000&slide=id.ge8392f138f_0_18)
- [RBS Rails を使って Rails アプリケーションに Steep を導入する](https://pocke.hatenablog.com/entry/2020/12/25/183535)
- [既存の gem に RBS で型定義を書く](https://blog.kymmt.com/entry/create-existing-gem-rbs-signature)
- [型のある Rails 開発を試してみる](https://zenn.dev/katsumanarisawa/articles/833b06ac80e1dc)
