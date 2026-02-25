# Global Claude Code Instructions

このファイルは全てのClaude Codeセッションに適用される個人的なルールと設定を定義します。

## 言語設定

- **レスポンス言語**: 日本語
- **説明スタイル**: 明確で簡潔に、必要に応じて詳細を提供
- **技術用語**: 英語の技術用語をそのまま使用し、必要に応じて日本語で補足

## コーディングスタイル

### インデント
- **基本**: 4スペースを使用
- タブ文字は使用しない
- エディタの設定と一貫性を保つ

### 命名規則
- **変数・関数**: camelCase (例: `getUserData`, `isValid`)
- **クラス**: PascalCase (例: `UserService`, `DataManager`)
- **定数**: UPPER_SNAKE_CASE (例: `MAX_RETRY_COUNT`, `API_BASE_URL`)
- **ファイル名**: kebab-case または PascalCase (プロジェクトの規約に従う)

### コードの品質
- 明確で読みやすいコードを優先
- 適切なコメントを追加（複雑なロジックや意図が不明瞭な箇所）
- DRY原則（Don't Repeat Yourself）を意識
- 関数は単一責任の原則に従う

## 開発ワークフロー

### Git
- コミットメッセージは明確に（何を、なぜ変更したか）
- 小さく頻繁にコミット
- ブランチ名は説明的に（例: `feature/user-auth`, `fix/api-timeout`）

### エラーハンドリング
- 適切なエラーハンドリングを実装
- エラーメッセージはユーザーフレンドリーに
- ログ出力は開発とプロダクションで適切に分ける

## Claude Code 固有の設定

### ツールの使用
- ファイル操作は専用ツール（Read, Edit, Write）を優先
- 並列実行可能な操作は並列で実行
- 大きな変更の前に計画を提示

### タスク管理
- 複雑なタスクはTodoWriteで管理
- タスクの進捗をリアルタイムで更新
- 完了したタスクは即座にマーク

### コミュニケーション
- 変更内容を明確に説明
- セキュリティやパフォーマンスの懸念点があれば指摘
- 必要に応じてファイルパスと行番号で参照（例: `file.ts:123`）

---

## カスタマイズ用セクション

以下のセクションは必要に応じて追加・編集してください。

### よく使う技術スタック
<!-- 例:
- フロントエンド: React, Next.js
- バックエンド: Node.js, Express
- データベース: PostgreSQL, Redis
- インフラ: Docker, AWS
-->

### プロジェクト固有のルール
<!-- プロジェクト横断的に適用したいルールを記述 -->

### 個人的な好み
<!-- その他の個人的な開発の好みや注意点 -->

## フロントエンド開発ガイドライン

フロントエンドUI（React, Vue, HTML/CSS等）を生成・修正する際は、
`~/.claude/skills/design/` のデザインガイドラインを参照すること。

### 参照すべきスキル
- `SKILL.md` - 概要とクイックチェックリスト
- `anti-patterns.md` - AIっぽいUIを避けるためのパターン集
- `typography.md` - フォント選択ルール（Inter, Roboto禁止）
- `theme.md` - カラーパレット（紫グラデーション禁止、ティール/エメラルド推奨）
- `background.md` - 背景デザインルール
- `motion.md` - アニメーション原則

### 必ず確認すること
- Inter, Roboto, Open Sans フォントを使用しない
- 紫グラデーション (`#667eea` → `#764ba2`) を使用しない
- 汎用青ボタン (`#007bff`) をそのまま使用しない
- 推奨カラー: ティール (`#0D9488`) / エメラルド (`#10B981`)

## Codex CLI レビュー連携

コードや方針について重要な判断が必要な場面では、Codex CLI にレビュー・議論を依頼する。
tmux-agent スキル（`~/.claude/skills/tmux-agent/SKILL.md`）を参照して操作すること。

### 発動条件（必須ルール）

以下の2つのタイミングで **必ず** Codex に相談する。例外なし。

#### ルール1: ファイルを編集する前

Edit / Write ツールを使ってコードを変更する **前に**、Codex に以下を相談する:
- 何を変更するか
- なぜその変更が必要か
- どのように実装するか

**例外（Codex 不要）**: typo 修正、コメントの修正、空白調整など、判断の余地がない1行の明らかな変更のみ

#### ルール2: 方針を決定した後

ユーザーからのタスクを受けて実装方針を決めたら、**実装に着手する前に** Codex にその方針をレビューしてもらう:
- 決めた方針の妥当性
- 見落としているリスクや代替案
- 実装順序の確認

### 連携モード

**常に対話モード（tmux pane 経由）を使用する。`codex exec` は使用禁止。**

対話モードは文脈を維持した複数ラウンドの議論が可能で、レビュー用途に最適。

#### 操作手順（必ずこの手順に従うこと）

1. **pane セットアップ**: codex pane がなければ作成・起動する
   ```bash
   # codex pane の検出
   CODEX_PANE=""
   while IFS='|' read -r idx pid cmd; do
       if pgrep -P "$pid" -f "codex" > /dev/null 2>&1; then
           CODEX_PANE=$idx; break
       fi
   done < <(tmux list-panes -F '#{pane_index}|#{pane_pid}|#{pane_current_command}')

   # なければ作成
   if [ -z "$CODEX_PANE" ]; then
       tmux split-window -h -p 40 -c "$(pwd)"
       CODEX_PANE=$(tmux list-panes -F '#{pane_index}' | tail -1)
       tmux send-keys -t .$CODEX_PANE "codex --no-alt-screen --full-auto" Enter
       sleep 5
   fi
   ```

2. **送信前スナップショット取得**:
   ```bash
   tmux capture-pane -t .$CODEX_PANE -p -S -200 \
       | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
       | sed '/^[[:space:]]*$/d' \
       > /tmp/tmux-before-snapshot.txt
   ```

3. **プロンプト送信（必ず別々の Bash 呼び出しで実行）**:
   ```bash
   # Bash 呼び出し1: テキスト入力
   tmux send-keys -t .$CODEX_PANE -l "レビュー依頼のテキスト"
   ```
   ```bash
   # Bash 呼び出し2: Enter で送信確定（必ず別の Bash 呼び出し！）
   tmux send-keys -t .$CODEX_PANE Enter
   ```

4. **完了待機ポーリング → 出力キャプチャ**:
   ```bash
   sleep 5  # 初回待機
   # 3秒間隔で "context left" パターン検出 or 出力安定化を待つ
   # 詳細は ~/.claude/skills/tmux-agent/output-parsing.md 参照
   tmux capture-pane -t .$CODEX_PANE -p -S -200 \
       | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
       | sed '/^[[:space:]]*$/d'
   ```

5. **差分抽出**: before スナップショットとの差分から新しい出力のみ取得

**禁止事項**: `codex exec` を使ってはならない。必ず上記の tmux pane 対話手順を踏むこと。

### レビュー依頼のフォーマット

Codex に送るプロンプトには以下を含める:

```
[レビュー依頼]
## 背景
（何をしようとしているか）

## 選択肢
（検討中のアプローチを列挙）

## 判断ポイント
（特に意見が欲しい点）

## コードコンテキスト
（関連するファイルパスや該当コードの抜粋）
```

### ワークフロー

1. 重要な判断に直面したら、まずユーザーに「Codex にレビューを依頼します」と報告
2. 上記の操作手順に従い、tmux pane で codex にレビュー依頼を送信
3. ポーリングで完了を待ち、codex の回答をキャプチャしてユーザーに共有
4. 必要に応じて追加の議論ラウンドを実施（同じ pane に追加送信）
5. 結論をまとめてユーザーに提示し、承認を得てから実装に着手

### 注意事項

- **`codex exec` は絶対に使わない** — 必ず tmux pane 対話で行う
- Codex の回答は参考意見として扱い、最終判断はユーザーに委ねる
- Codex とのやりとりは常にユーザーに可視化する（隠さない）
- レビュー議論に時間がかかりすぎる場合は、途中経過をユーザーに報告する

## Obsidian Vault統合

Claude Codeセッションでは、以下のObsidian vaultを参照できます:

- **Vaultパス**: `${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian_Vault`
- **主要なディレクトリ**:
  - `IT用語集/` - 技術用語の定義と解説
  - `参考論文/` - 研究・技術論文のメモ
  - `Clippings/` - Webクリッピング
  - その他のプロジェクトノート

**使用方法**:
- 必要に応じてObsidianノートの内容を参照してコンテキストを提供
- 技術用語や概念の説明が必要な場合はIT用語集を確認
- プロジェクト関連の背景情報はObsidianノートから取得可能

### Research スキル（自動発動）

「調べて」「まとめて」「〇〇とは」という表現が含まれたら、
`~/.claude/skills/obsidian-research/SKILL.md` を参照してリサーチ＆保存ワークフローを実行すること。

**保存先**:
- URL 指定 → `Clippings/`
- IT/技術系の用語定義 → `IT用語集/`
- その他 → `調査メモ/`（YYYY-MM-DD プレフィックス付き）

**誤発動抑止ルール**:
- 「調べて」「まとめて」であっても、コーディング作業の文脈（ファイルを読む・デバッグする等）では発動しない
- ユーザーが明示的に「保存しないで」「メモ不要」と言った場合は発動しない
- コードのエラー調査・ライブラリの使い方確認など、回答だけで完結する文脈でも発動しない

**機密情報除外ルール**:
- 個人情報・APIキー・「社外秘」「機密」とラベルされた情報は保存拒否
- 保存前にユーザーへ警告する

**コマンド**: `/research [トピック名]`
