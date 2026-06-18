# Codex Limit Statusline

Codex CLIのTUI下部に、利用枠の残量と直近ターンのtoken使用量を表示します。

このインストーラはCodex本体や認証情報には触らず、次の設定だけを追加します。

```toml
[tui]
status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]
```

インストール後はCodexを再起動してください。

## インストール

以下のコマンドは変更できないコミットからスクリプトを取得し、実行前にSHA-256を検証します。コミット番号をブランチ名へ変更しないでください。

### Windows PowerShell

```powershell
$commit = "a563f261205fb13df2d94596eaab95fe67874a3a"
$expected = "78ec6a8d240bc88fb111c3faa49ff86d41c4292cde2eaa63532b2b8955617e77"
$url = "https://raw.githubusercontent.com/uri-uri/codex/$commit/install.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-install.ps1"

try {
  Invoke-WebRequest $url -OutFile $file
  $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash.ToLowerInvariant()
  if ($actual -ne $expected) { throw "SHA-256 verification failed" }
  powershell -NoProfile -ExecutionPolicy Bypass -File $file
} finally {
  Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}
```

### macOS / Linux

```sh
commit="a563f261205fb13df2d94596eaab95fe67874a3a"
expected="e7af80460a58cad5ccbfb68b4938a34b4b770573fbee67d03a8d2f088dc97670"
url="https://raw.githubusercontent.com/uri-uri/codex/$commit/install.sh"
file="$(mktemp "${TMPDIR:-/tmp}/codex-limit-statusline-install.XXXXXX")"

curl -fsSL "$url" -o "$file"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$file" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
fi
[ "$actual" = "$expected" ] || { rm -f "$file"; echo "SHA-256 verification failed" >&2; exit 1; }
sh "$file"
rm -f "$file"
```

## 変更内容

- `~/.codex/config.toml`がなければ作成します。
- `[tui].status_line`を追加または更新します。
- 既存設定を置き換える前に、一意な名前のバックアップを作成します。
- 同じディレクトリ内で原子的に設定ファイルを置き換えます。
- `config.toml`がシンボリックリンクまたはreparse pointなら処理を拒否します。
- Unixでは設定ファイルとバックアップを権限`600`で保存します。
- 失敗時も一時ファイルを削除します。
- Codexの認証ファイルは読み書きしません。
- パッケージやCodex本体をインストール・置換しません。
- ダウンロード済みスクリプトの開始後はネットワーク通信しません。

## アンインストール

### Windows PowerShell

```powershell
$commit = "a563f261205fb13df2d94596eaab95fe67874a3a"
$expected = "8aec301aa42cc7fdfaa55d6bd3d554e39e06c633f6571f47c92beeb15eaa8bf1"
$url = "https://raw.githubusercontent.com/uri-uri/codex/$commit/uninstall.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-uninstall.ps1"

try {
  Invoke-WebRequest $url -OutFile $file
  $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash.ToLowerInvariant()
  if ($actual -ne $expected) { throw "SHA-256 verification failed" }
  powershell -NoProfile -ExecutionPolicy Bypass -File $file
} finally {
  Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}
```

### macOS / Linux

```sh
commit="a563f261205fb13df2d94596eaab95fe67874a3a"
expected="39363f620ddbea3b70cc6d16400aa707087c9f40d0e44d974fc4770ae53768cc"
url="https://raw.githubusercontent.com/uri-uri/codex/$commit/uninstall.sh"
file="$(mktemp "${TMPDIR:-/tmp}/codex-limit-statusline-uninstall.XXXXXX")"

curl -fsSL "$url" -o "$file"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$file" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
fi
[ "$actual" = "$expected" ] || { rm -f "$file"; echo "SHA-256 verification failed" >&2; exit 1; }
sh "$file"
rm -f "$file"
```

アンインストーラは、この設定と完全に一致する`status_line`だけを削除します。以前の独自設定へ戻す場合は、タイムスタンプ付きバックアップを復元してください。

## 表示例

```text
5h 99% left
weekly 61% left
last 1.45K
```

## 注意

残量の警告色やリセット時刻にはCodex TUI本体の改修が必要です。`feature/status-line-rate-limit-alerts`は古いOpenAI Codexを基にした実験ブランチであり、保守された実行ファイル配布ではありません。

セキュリティ方針と非公開の報告先は[SECURITY.md](SECURITY.md)を参照してください。
