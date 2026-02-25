# /sec-white — White Hacker 単体実行

> 防衛者視点のセキュリティ評価と対策立案を実行するコマンド。
> 既存の threat-model.md がある場合はそれを読み込んで統合対策を策定する。
> 包括的なレビューには `/sec-review` を使用してください。

## 引数

$ARGUMENTS

## 実行手順

### Step 0: スキル読み込み

以下のスキルファイルを読み込む:
- `~/.claude/skills/security-review/ethics.md`
- `~/.claude/skills/security-review/white-hacker.md`
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

ただし、既に `docs/security/{target-name}/authorization-record.md` が存在し、有効期間内である場合はスキップ可能。その場合、既存の authorization-record.md の SHA-256 ハッシュを検証する。

### Step 2: 監査証跡の確認/生成

既存の `authorization-record.md` がない場合:
- threat-model-template.md のフォーマットに従って新規生成
- SHA-256 ハッシュを計算して付与

既存の `authorization-record.md` がある場合:
- SHA-256 ハッシュを再計算して整合性を検証
- 不一致の場合はユーザーに警告し、再認証を要求

### Step 3: 既存 threat-model.md の確認

`docs/security/{target-name}/threat-model.md` が存在するか確認する。

**存在する場合**: Phase 4 モード（統合対策）
- threat-model.md を読み込み
- 独立分析をスキップし、直接 defense-strategy.md を生成

**存在しない場合**: Phase 3 → Phase 4 モード（独立分析 + 対策）
- まず independent-assessment.md を生成（独立分析）
- その後、独立分析結果に基づいて defense-strategy.md を生成

### Step 4: 独立分析（threat-model.md がない場合のみ）

white-hacker.md の Phase 3 思考フローに従い:
1. 対象のソースコードを Read で読み込む
2. Defense-in-Depth の各層を評価
3. NIST CSF の5機能を評価
4. 防御のギャップを特定

`docs/security/{target-name}/independent-assessment.md` を生成:
- threat-model-template.md のフォーマットに従う
- 各評価は ASSESSMENT-N 形式
- v1 Freeze Record を付与

### Step 5: 防御戦略策定

white-hacker.md の Phase 4 思考フローに従い:
1. threat-model.md（存在する場合）または独立分析結果を基に対策を策定
2. 各脅威/ギャップに対する防御策を立案
3. 優先度（P0〜P3）を付与
4. 残留リスクを評価

`docs/security/{target-name}/defense-strategy.md` を生成:
- threat-model-template.md のフォーマットに従う
- 各対策は DEFENSE-N 形式

### Step 6: 完了報告

ユーザーに以下を報告:
- 策定された対策の数（優先度別）
- 生成されたファイルのパス
- `.gitignore` 推奨メッセージ
- 次のステップの提案:
  - threat-model.md がない場合: `/sec-black` で攻撃者視点を追加、または `/sec-review` で包括的レビュー
  - 対策が揃った場合: `/kairo-tasks` で対策実装タスクを生成
