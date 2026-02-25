# /sec-black — Black Hacker 単体実行

> 攻撃者視点の脅威分析を素早く実行する軽量コマンド。
> 包括的なレビューには `/sec-review` を使用してください。

## 引数

$ARGUMENTS

## 実行手順

### Step 0: スキル読み込み

以下のスキルファイルを読み込む:
- `~/.claude/skills/security-review/ethics.md`
- `~/.claude/skills/security-review/black-hacker.md`
- `~/.claude/skills/security-review/threat-model-template.md`

### Step 1: Authorization Gate

**ethics.md の Authorization Gate を実行する。**

AskUserQuestion で以下を確認:
1. 対象システムの所有者/授権者からの許可があるか
2. テスト範囲（スコープ）
3. テスト期間
4. 承認者名（任意: 許可ID）
5. データ分類レベル（PUBLIC / INTERNAL / CONFIDENTIAL / RESTRICTED）
6. 発見した脆弱性の報告先
7. 禁止行為（ethics.md の絶対禁止事項）への同意

**1項目でも未確認 → hard fail で停止。**

### Step 2: 監査証跡の生成

`docs/security/{target-name}/authorization-record.md` を threat-model-template.md のフォーマットに従って生成する。

SHA-256 ハッシュの計算:
- authorization セクションの内容をシリアライズ
- Bash で `echo -n "{内容}" | shasum -a 256` を実行
- 結果を `sha256` フィールドに記録

### Step 3: 対象分析

引数で指定された対象（ファイル、ディレクトリ、モジュール）を分析する。
引数が空の場合はプロジェクトルート全体を対象とする。

1. 対象のソースコードを Read で読み込む
2. アーキテクチャ・依存関係を把握
3. 外部接点を特定

### Step 4: 脅威分析

black-hacker.md の思考フローに従い:
1. 資産を特定
2. 攻撃経路を列挙（STRIDE / OWASP Top 10）
3. 脅威シナリオを構築
4. CVSS v3 ベーススコアを概算

### Step 5: threat-model.md 生成

`docs/security/{target-name}/threat-model.md` を生成する:
- threat-model-template.md のフォーマットに従う
- 各脅威は THREAT-N 形式
- 機密分類ヘッダを付与
- v1 Freeze Record を付与

### Step 6: 完了報告

ユーザーに以下を報告:
- 検出された脅威の数（深刻度別）
- 生成されたファイルのパス
- `.gitignore` 推奨メッセージ
- 次のステップの提案（`/sec-white` で対策立案、または `/sec-review` で包括的レビュー）
