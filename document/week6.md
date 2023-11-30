# vscode-steep を使う

## 目次

1. 概要
2. どのような機能を提供するか？
3. 言語サーバーとは？
4. 拡張機能はいつアクティブになるのか？
5. 言語サーバーとはどのタイミングで通信が開始するのか？

## 概要

タイムリーに静的型検査を行い、エディタ上にその結果を表示することで開発体験を向上させる vscode の拡張機能。使用するには拡張機能と Steep のインストールが必要<br>
Steep が静的型検査、LSP がエディタと静的型検査を行う言語サーバーとの通信、VS Code API がエディタのイベント検知や装飾を行っている<br>
[vscode-steep](https://github.com/soutaro/steep-vscode)

#### Steep とは

RBS を使って Ruby の静的型検査を行ってくれる gem<br>
[steep](https://github.com/soutaro/steep)

#### LSP とは

[LSP(language server protocol)](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/)とは、ソースコードの解析や補完、定義ジャンプなどの機能を提供するために、エディタ、IDE（クライアント）と言語サーバー（language server）との間で通信する Microsoft が定めた規格のこと<br>
HTTP と同等のプロトコルであり、ヘッダー部分とコンテンツ部分からなる。コンテンツ部分で扱う、リクエスト、レスポンスのパラメータは以下のように[JSON-RPC](https://ja.wikipedia.org/wiki/JSON-RPC)を使用する

```json
{
	"jsonrpc": "2.0",
	"id": 1,
	"method": "textDocument/completion",
	"params": {
		...
	}
}
```

#### VS Code API とは

[VS Code API](https://code.visualstudio.com/api/references/vscode-api)とは、Visual Studio Code の拡張機能で呼び出すことができる JavaScript API セット。イベントハンドラーやエディタを装飾したりする関数などが用意されている<br>
例えば、[vscode.workspace.onDidChangeWorkspaceFolders](https://code.visualstudio.com/api/references/vscode-api#workspace)だとワークスペースにフォルダが追加または削除されたときに発行されるイベントハンドラー。また、[setDecorations](https://code.visualstudio.com/api/references/vscode-api#TextEditor)だと decorationType と range を指定して、テキストに装飾することができる

## どのような機能を提供するか？

以下の機能を提供する<br>

1. 静的型検査のエラーを表示する
2. メソッドの候補を表示する
3. ホバーで型情報を取得する

vscode-steep では、拡張機能がアクティブになった時に、[TypeCheckWorker](https://github.com/soutaro/steep/blob/f68f477d6050cd0d2bd80f38c4645f72b7b04a11/lib/steep/server/type_check_worker.rb#L3) と [InteractionWorker](https://github.com/soutaro/steep/blob/f68f477d6050cd0d2bd80f38c4645f72b7b04a11/lib/steep/server/interaction_worker.rb#L3) の 2 種類の言語サーバーが立ち上がる<br>

- TypeCheckWorker
  - 静的型検査のエラーを表示する(Notification Message)
- InteractionWorker
  - メソッドの候補を表示する(Request Message / Response Message)
  - ホバーで型情報を取得する(Request Message / Response Message)

**図 1.エディタ上に静的型検査のエラーを作画する**<br>
[![Image from Gyazo](https://i.gyazo.com/572875077a3f4850553011075020a185.gif)](https://gyazo.com/572875077a3f4850553011075020a185)<br>
**図 2.メソッドの候補を表示する**<br>
[![Image from Gyazo](https://i.gyazo.com/bb2c39fe6506898913b6ed2ea0b75f82.gif)](https://gyazo.com/bb2c39fe6506898913b6ed2ea0b75f82)<br>
**図 3.ホバーで型情報を取得する**<br>
[![Image from Gyazo](https://i.gyazo.com/fe1e51f879db718a61408bdcfd5e652a.gif)](https://gyazo.com/fe1e51f879db718a61408bdcfd5e652a)<br>

## 言語サーバーとは？

エディタからのリクエストをもとに、LSP のルールに従ってエディタにパラメータを返すプロセス(Job)<br>
Steep の`steep langserver`コマンドで言語サーバーのプロセスを立ち上げる。このコマンドは、vscode の拡張機能がアクティブかつその他条件を満たした時に呼ばれる

#### steep langserver が提供する機能

例えば[TypeCheckWorker](https://github.com/soutaro/steep/blob/f68f477d6050cd0d2bd80f38c4645f72b7b04a11/lib/steep/server/type_check_worker.rb#L3) であれば、`handle_requestメソッド`でどのようなリクエストに対して、どのような処理を行うかがわかる。`handle_jobメソッド`を見ればどのようなパラメータをエディタに返すのかわかる<br>

```ruby
def handle_request(request)
  case request[:method]
  ...
  when "$/typecheck/start"
   params = request[:params]
   enqueue_typecheck_jobs(params) # ValidateAppSignatureJobがキューされる
end

def handle_job(job)
  case job
  when ValidateAppSignatureJob
 ...
    writer.write(
      method: :"textDocument/publishDiagnostics",
      params: LSP::Interface::PublishDiagnosticsParams.new(
        uri: Steep::PathHelper.to_uri(job.path).to_s,
        diagnostics: diagnostics.map {|diagnostic| formatter.format(diagnostic) }.uniq
      )
    )
  end
```

**図 4.言語サーバーから送られてくるパラメータ**<br>
vscode-steep に console.log を埋め込み、デバックモード動作を確認<br>
[![Image from Gyazo](https://i.gyazo.com/90160d16967eb490d7fa212b538ed536.png)](https://gyazo.com/90160d16967eb490d7fa212b538ed536)

#### steep langserver にリクエストを送るには？

[LanguageServer::Protocol::Transport::Io](https://github.com/mtsmfm/language_server-protocol-ruby)ライブラリを使って、リクエストとレスポンスのやり取りをエディタと言語サーバー間で行っている<br>
ただ、ターミナルで`steep langserver`を起動するとプロセスの標準入力がターミナルになったため、パイプ等を使ってエディタを使わずにリクエストを送ることもできそう

```
$ ps | grep steep
PID TTY           TIME CMD
49776 ttys014    0:02.02 /Users/kawaiyuya/projects/practice_rbs_rails/vendor/bundle/ruby/3.2.0/bin/steep langserver

# steep languageserverのファイルディスクプリタを確認
# 標準入力、標準出力、標準エラー出力がttys(ターミナルになっている)
$ lsof -p 49776
...
ruby    49776 kawaiyuya    0u   CHR               16,6  0t76279     2563 /dev/ttys006
ruby    49776 kawaiyuya    1u   CHR               16,6  0t76279     2563 /dev/ttys006
ruby    49776 kawaiyuya    2u   CHR               16,6  0t76279     2563 /dev/ttys006

# LSPに準拠したlsp_request.jsonが作成できれば、エディタに返す標準出力のレスポンスが見れそう
$ cat lsp_request.json | bundle exec steep langserver
```

#### stylelint の例

vscode の拡張機能はローカルの`~/.vscode/extensions`に保存されている。例えば stylelint だと vscode を立ち上げた際に、[プロセス](https://code.visualstudio.com/api/advanced-topics/extension-host)が起動する

```terminal
$ cd ~/.vscode/extensions
$ ls | grep stylelint.vscode-stylelint-1.3.0
stylelint.vscode-stylelint-1.3.0

# ローカルマシンで動いているデーモンも含めたプロセスを全て表示する
$ ps aux | grep stylelint
kawaiyuya        43523   0.0  0.1 1211024908  11988   ??  S    10:30PM   0:04.02 /Applications/Visual Studio Code.app/Contents/Frameworks/Code Helper (Plugin).app/Contents/MacOS/Code Helper (Plugin) --ms-enable-electron-run-as-node /Users/kawaiyuya/.vscode/extensions/stylelint.vscode-stylelint-1.3.0/dist/start-server.js --stdio --clientProcessId=43491
```

## 拡張機能はいつアクティブになるのか？

package.json の`activationEvents`に定義されているイベントが発火した時に、拡張機能がアクティブになる。拡張機能がアクティブになると extension.ts に定義されている`activate関数`が動く<br>
`activate関数`内で言語サーバーとの通信を開始するロジックが書かれているが、VS Code API のイベントハンドラでラップされていることがほとんどのため、拡張機能がアクティブになる度に通信が行われるわけではない<br>

```json
// package.json
{
	"activationEvents": [
      // ファイルがオープンされた時に拡張機能がactiveになる
      // https://code.visualstudio.com/api/references/activation-events#workspaceContains
		"workspaceContains:."
	],
   ...
}
```

```javascript
// extension.ts
export async function activate(context: vscode.ExtensionContext) {
   ...
   // context.subscriptions に追加することで、拡張機能が非アクティブになった時に、追加したイベントハンドラが解放される
   // vscode.workspace.onDidChangeWorkspaceFoldersはVS Code APIのイベントハンドラで、ワークスペース内のファイル構成の変化イベントを取得する
	context.subscriptions.push(
		vscode.workspace.onDidChangeWorkspaceFolders(async (event) => {
			console.log("onDidChangeWorkspaceFolders:", event)

			for (const folder of event.added) {
				startSteep(folder) // 言語サーバーとのやり取りを開始する
			}
			for (const folder of event.removed) {
				if (_clientSessions.has(folder)) {
					stopSteep(folder)
				}
			}
		})
	)
   ...
}
```

## 言語サーバーとはどのタイミングで通信が開始するのか？

コードで通信タイミングを追うのは難しいため、出力タブで通信が行われているかを確認する<br>

```terminal
# ファイルを開いた時のアクション
[Steep 1.5.3] [typecheck:typecheck@1] [frontend] Received message from master: $/typecheck/start()
[Steep 1.5.3] [typecheck:typecheck@1] [frontend] Enqueueing StartTypeCheckJob for guid=833bc671-e0a1-4f0d-826c-b5b043b110f8
[Steep 1.5.3] [typecheck:typecheck@1] [background] Processing StartTypeCheckJob for guid=833bc671-e0a1-4f0d-826c-b5b043b110f8
[Steep 1.5.3] [typecheck:typecheck@1] [background] #update_signature took 0.004155 seconds

# hoverした時のアクション
[Steep 1.5.3] [interaction:interaction] [frontend] Received message from master: textDocument/hover(YJFldFIiIg)
[Steep 1.5.3] [interaction:interaction] [background] [#handle_job] [#process_hover] path=app/models/todo.rb, line=28, column=9
[Steep 1.5.3] [interaction:interaction] [background] [#handle_job] [#process_hover] Generating hover response took 0.177024
```

- 静的型検査のエラーを表示
  - ファイルを開いた時、前回と比べて差分があれば通信をしていると思われる
- メソッドの候補の表示、ホバーで型情報を取得
  - エディタでそのイベントを行ったタイミングで通信をしていると思われる

**図 5.静的型検査のエラー**<br>
[![Image from Gyazo](https://i.gyazo.com/14585f9632feec73a81d2d71ce6fa373.gif)](https://gyazo.com/14585f9632feec73a81d2d71ce6fa373)

## まとめ

- vscode-steep には、以下の機能がある。静的型検査のエラー内容は Steep の実装に依存する
  - 静的型検査のエラーを表示する
  - メソッドの候補を表示する
  - ホバーで型情報を取得する
- LSP の機能が使えるのは、ローカルマシンのバックグラウンドプロセスで Steep の言語サーバーが立ち上がっているため
- エディタと言語サーバーがやり取りするタイミングは以下のような時だと思われる
  - 静的型検査のエラーを表示は、ファイルを開いた時、前回と比べて差分があれば通信をしている
  - メソッドの候補の表示、ホバーで型情報を取得は、エディタでそのイベントを行ったタイミングで通信をしている
