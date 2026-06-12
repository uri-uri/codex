# Codex Limit Statusline

Codex CLI の TUI 下部フッターに、レート制限の残量と直近ターンの token 使用量を表示します。

これは既に Codex をインストール済みのユーザー向けの小さなインストーラです。Codex 本体や認証情報には触らず、Codex の設定ファイルだけを更新します。

追加される設定:

```toml
[tui]
status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]
```

インストール後は Codex を再起動してください。

## インストール

### Windows PowerShell

```powershell
$url = "https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/install.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-install.ps1"
Invoke-WebRequest $url -OutFile $file
powershell -ExecutionPolicy Bypass -File $file
```

### macOS / Linux

```sh
url="https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/install.sh"
file="${TMPDIR:-/tmp}/codex-limit-statusline-install.sh"
curl -fsSL "$url" -o "$file"
sh "$file"
```

## 変更される内容

- `~/.codex/config.toml` がなければ作成します。
- `[tui].status_line` を追加または更新します。
- 既存の設定ファイルを変更する前に、タイムスタンプ付きバックアップを作成します。
- Codex の認証ファイルは読みません。
- パッケージはインストールしません。
- インストーラ実行後に追加のネットワーク通信はしません。
- Codex の実行ファイルは置き換えません。

## アンインストール

### Windows PowerShell

```powershell
$url = "https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/uninstall.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-uninstall.ps1"
Invoke-WebRequest $url -OutFile $file
powershell -ExecutionPolicy Bypass -File $file
```

### macOS / Linux

```sh
url="https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/uninstall.sh"
file="${TMPDIR:-/tmp}/codex-limit-statusline-uninstall.sh"
curl -fsSL "$url" -o "$file"
sh "$file"
```

アンインストールスクリプトは、このインストーラが追加する `status_line` 設定を削除します。以前に独自の status line を設定していた場合は、インストール時に作成されたバックアップから戻してください。

## 表示例

Codex では残りの利用枠として表示されます。

```text
5h 99% left
weekly 61% left
last 1.45K
```

`left` は「残り」という意味です。たとえば `5h 99% left` は、5時間枠が99%残っているという意味です。

## 注意

残量が少ないときに黄色や赤で警告する機能や、`reset 3h12m` / `reset 6/18 19:35` のような回復時刻表示には、Codex TUI 本体側の対応が必要です。設定ファイルだけを変更するこのインストーラでは、安全に色付き警告や reset 表示を追加することはできません。

本体改修ブランチはこちらです。

```text
https://github.com/uri-uri/codex/tree/feature/status-line-rate-limit-alerts
```
