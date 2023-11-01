# LSP で開発体験を向上させる

## 目次

1. LSP とは
   1. 警告を表示する
   2. メソッド候補を表示する
   3. ホバーでヒントを表示する
2. LSP を開発環境で動作させるためには
3. LSP の種類
   1. vscode-steep
   2. vscode-typeprof

## LSP とは

[LSP(language server protocol)](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/)とは、ソースコードの解析や補完、定義ジャンプなどの機能を提供するために、エディタ、IDE（クライアント）と言語サーバー（language server）との間で通信する規格のこと。<br>
[JSON-RPC](https://ja.wikipedia.org/wiki/JSON-RPC) を介して、以下 2 種類の方法で通信している<br>

1. Request Message / Response Message
2. Notification Message(一方方向のため、レスポンス不要)

**図 1. Message パラメータの例**

```json
// Request Message / Notification Message
{
	"jsonrpc": "2.0",
	"id": 1,
	"method": "textDocument/completion",
	"params": {
		...
	}
}

// Response Message
{
	"jsonrpc": "2.0",
	"id": 1,
	"result": {
    ...
  },
	"error": {
		...
	}
}
```

**図 2. LSP の通信の例 [参考文献](https://learn.microsoft.com/ja-jp/visualstudio/extensibility/language-server-protocol?view=vs-2022)**
[![Image from Gyazo](https://i.gyazo.com/d3fcf2e41ab7a5104125104aba362f03.png)](https://gyazo.com/d3fcf2e41ab7a5104125104aba362f03)

### 警告を表示する

1. エディタでコードを開く or 変更すると Notification Message `textDocument/didOpen` or `textDocument/didChange`が言語サーバーにリクエストされる。
2. 言語サーバーで上記のリクエストを受け取り、特定の処理が動く。(ex. steep check 等)
3. 処理が終了したら、言語サーバーから Notification Message `textDocument/publishDiagnostics` で診断結果をエディタに返す。
4. 受け取った診断結果を元にエディタが警告を作画する。

[textDocument/publishDiagnostics](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_publishDiagnostics)

```typescript
interface PublishDiagnosticsParams {
  uri: DocumentUri; // 対象のファイル
  // ex.file:///c:/project/readme.md

  diagnostics: Diagnostic[]; // 診断結果
}

interface Diagnostic {
  range: Range; // 対象の位置
  // ex.{ start: { line: 5, character: 23 }, end : { line: 6, character: 0 }}

  severity?: DiagnosticSeverity; // メッセージの重要度
  // ex.Error, Warning, Infomation, Hint

  message: string; // メッセージの内容
}
```

### メソッド候補を表示する

1. エディタで特定の文字を入力したりすると Request Message `textDocument/completion` が言語サーバーにリクエストされる。
2. 言語サーバーで上記のリクエストを受け取り、特定の処理が動いた後、レスポンスを返す。
3. 受け取ったレスポンスを元にエディタがメソッド候補を表示する。

[textDocument/completion](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_completion)

```typescript
// Request Message
interface CompletionParams {
  context: {
    triggerKind: CompletionTriggerKind; // コード補完がどのようにしてトリガーされたかを示す数値
    // ex. 1 明示的にコード補完を呼び出した時
    // ex. 2 特定の文字が入力された時(ドットなど)
    triggerCharacter?: string; // コード補完がトリガーした文字
    // ex. ., :
  };
}

// Response Message
interface CompletionList {
  itemDefaults?: {
    editRange?: Range; // 対象の位置
  };

  items: CompletionItem[]; // メソッドの候補リスト(パラメータが多く複雑なため割愛)
}
```

### ホバーでヒントを表示する

1. エディタで特定の文字を入力すると Request Message `textDocument/hover` が言語サーバーにリクエストされる。
2. 言語サーバーで上記のリクエストを受け取り、特定の処理が動いた後、レスポンスを返す。
3. 受け取ったレスポンスを元にエディタがメソッド候補を表示する。

[textDocument/hover](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_hover)

## LSP を開発環境で動作させるためには

LSP ごとに指定の gem がインストールされている必要がある。Solargraph だと solargraph gem、vscode-steep だと steep gem のインストールが必要になる。

### Dev container

vscode の拡張機能。
docker container 内で vscode server を立ち上げ、ローカルからそのサーバーに接続する。docker container 内で vscode を立ち上げている状態になるため、ローカルで gem のインストールが必要ない

**図 3. Dev container の仕組み [参考文献](https://code.visualstudio.com/docs/devcontainers/containers)**
[![Image from Gyazo](https://i.gyazo.com/ea71e87a29f9de9ace9811f566ad543b.png)](https://gyazo.com/ea71e87a29f9de9ace9811f566ad543b)

**図 4. Dev container の動き**

#### 注意点

- 接続後のデフォルトの path が、/root のため、特定の path に切り替えるにつようがある。
- docker container 内の vscode server で拡張機能を再インストールする必要がある
  - => [devcontainer.json](https://containers.dev/implementors/json_reference/#lifecycle-scripts) でコンテナのライフサイクルに紐づけて path のマッピングや拡張機能のインストールすることができるらしいです
- workspace で開くことができない

## LSP の種類

型情報を活用できる LSP は、vscode-steep と vscode-typeprof になるため、これらを紹介する。(型情報を活用できないが、有名な LSP Solargraph や RubyLSP がある)

### vscode-steep

### vscode-typeprof
