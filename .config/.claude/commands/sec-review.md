# /sec-review — 双子エージェント統合セキュリティレビュー

> Black Hacker（攻撃者視点）と White Hacker（防衛者視点）の双子エージェントを
> TeamCreate でチーム起動し、Hybrid 方式で包括的セキュリティレビューを実施する。

## 引数

$ARGUMENTS

オプション: `--no-debate` — Debate フェーズ（Phase 5）をスキップする

## 実行手順

### Step 0: スキル読み込み

以下のスキルファイルを **全て** 読み込む:
- `~/.claude/skills/security-review/SKILL.md`
- `~/.claude/skills/security-review/ethics.md`
- `~/.claude/skills/security-review/black-hacker.md`
- `~/.claude/skills/security-review/white-hacker.md`
- `~/.claude/skills/security-review/threat-model-template.md`

---

## Phase 1: Authorization Gate

**ethics.md の Authorization Gate を実行する。**

AskUserQuestion で以下の7項目を確認:
1. 対象システムの所有者/授権者からの許可があるか
2. テスト範囲（スコープ）
3. テスト期間（開始日〜終了日）
4. 承認者名（任意: 許可ID）
5. データ分類レベル（PUBLIC / INTERNAL / CONFIDENTIAL / RESTRICTED）
6. 発見した脆弱性の報告先
7. 禁止行為（ethics.md の絶対禁止事項）への同意

**1項目でも未確認 → hard fail:**
```
❌ Authorization Gate FAILED
未確認項目: {項目名}
セキュリティレビューは授権が確認されるまで実行できません。
```

Gate 通過時:
- `docs/security/{target-name}/` ディレクトリを作成
- `authorization-record.md` を生成（SHA-256 ハッシュ + retention 90日）

---

## Phase 2: チームセットアップ

TeamCreate でセキュリティレビューチームを作成する:

```
チーム名: sec-review-{target-name}
```

タスクを3つ作成:

| タスクID | 名前 | 担当 | 依存 |
|---------|------|------|------|
| TASK-001 | 攻撃者視点の脅威分析 | black-hacker | なし |
| TASK-002 | 防衛者視点の独立分析 | white-hacker | なし |
| TASK-003 | Debate ラウンド | リーダー | TASK-001, TASK-002 |

---

## Phase 3: 並列独立分析（Hybrid 前半）

Task ツールで black-hacker と white-hacker を **並列起動** する。

### black-hacker エージェント（TASK-001）

```
subagent_type: general-purpose
team_name: sec-review-{target-name}
name: black-hacker
```

プロンプト:
```
あなたは black-hacker（攻撃者視点の脅威分析エージェント）です。

## スキル読み込み
~/.claude/skills/security-review/ethics.md と
~/.claude/skills/security-review/black-hacker.md を読み込んでください。

## 授権情報
対象: {target-name}
スコープ: {スコープ}
分類: {分類レベル}

## タスク
1. 対象のソースコードを分析
2. STRIDE / OWASP Top 10 に基づく脅威分析を実施
3. docs/security/{target-name}/threat-model.md を生成
4. v1 Freeze Record を付与

## 重要
- ethics.md の禁止事項を厳守
- 実際の攻撃コードは生成しない
- 分析は white-hacker の出力を参照せず独立で行う
- 完了後は TASK-001 を completed にマーク
```

### white-hacker エージェント（TASK-002）

```
subagent_type: general-purpose
team_name: sec-review-{target-name}
name: white-hacker
```

プロンプト:
```
あなたは white-hacker（防衛者視点の独立分析エージェント）です。

## スキル読み込み
~/.claude/skills/security-review/ethics.md と
~/.claude/skills/security-review/white-hacker.md を読み込んでください。

## 授権情報
対象: {target-name}
スコープ: {スコープ}
分類: {分類レベル}

## タスク
1. 対象のソースコードを分析
2. Defense-in-Depth / NIST CSF に基づく独立評価
3. docs/security/{target-name}/independent-assessment.md を生成
4. v1 Freeze Record を付与

## 重要
- ethics.md の禁止事項を厳守
- 分析は black-hacker の出力を参照せず独立で行う
- threat-model.md は読まない
- 完了後は TASK-002 を completed にマーク
```

**★ v1 Freeze**: 両エージェントの出力が確定するまで Phase 4 に進まない。
TaskList で TASK-001 と TASK-002 が両方 completed になるのを確認する。

---

## Phase 4: 逐次統合（Hybrid 後半）

両エージェントの出力を交換して統合する。

### Step 4a: white-hacker 統合

Task ツールで white-hacker を起動:

```
あなたは white-hacker（防衛者視点の統合対策エージェント）です。

## スキル読み込み
~/.claude/skills/security-review/white-hacker.md を読み込んでください。

## タスク
1. docs/security/{target-name}/threat-model.md を読み込む（v1 Freeze 済み）
2. docs/security/{target-name}/independent-assessment.md と照合
3. docs/security/{target-name}/defense-strategy.md を生成
   - 各 THREAT に対する防御策を DEFENSE-N 形式で記述
   - 優先度 P0〜P3 を付与
   - 残留リスクを評価
```

### Step 4b: black-hacker 補足

Task ツールで black-hacker を起動:

```
あなたは black-hacker（脅威モデル補足エージェント）です。

## タスク
1. docs/security/{target-name}/independent-assessment.md を読み込む（v1 Freeze 済み）
2. white-hacker の独立分析から、自分が見落とした観点を確認
3. 見落としがあれば docs/security/{target-name}/threat-model.md の
   "Phase 4 Amendments" セクションに追記
4. 見落としがなければ「追加なし」と記録
```

### Conflict Resolution

Phase 4 で black/white の評価が衝突した場合:
1. **深刻度が高い方の評価を採用**（conservative principle）
2. 両者の根拠を review-summary.md の "Conflicts" セクションに併記
3. 最終判断はユーザーに委ねる（自動マージしない）

---

## Phase 5: Debate ラウンド

> **デフォルト ON**。`--no-debate` が指定された場合はスキップ。

### Safety Bounds
- **1ラウンド上限**: black → white の1往復のみ
- **概念的指摘のみ**: 実装可能な攻撃手順の新規生成は禁止
- **既存脅威の深堀りのみ**: Phase 3 で特定済みの THREAT-N に対する防御の不足指摘

### Debate 実行

Task ツールで black-hacker を起動:

```
あなたは black-hacker（Debate エージェント）です。

## Safety Bounds
- 概念的な指摘のみ（攻撃コード・新規攻撃手順の生成禁止）
- threat-model.md にない新規脅威の追加禁止
- 1ラウンドのみ

## タスク
1. docs/security/{target-name}/defense-strategy.md を読み込む
2. 防御策の穴・不足を概念レベルで指摘
3. 指摘事項を出力（新規ファイルは作成しない）
```

指摘事項を受けて white-hacker を起動:

```
あなたは white-hacker（Debate 応答エージェント）です。

## タスク
1. black-hacker の指摘事項を確認
2. defense-strategy.md を補強（該当 DEFENSE エントリの更新または追加）
3. 対応できない指摘は残留リスクとして記録
```

---

## Phase 6: 統合レポート生成

リーダー（自分）が以下を生成する:

### review-summary.md

threat-model-template.md のフォーマットに従い:
- レビュー概要
- 脅威サマリー（深刻度別件数、対策状況）
- 主要な発見事項
- 推奨アクション（優先順）
- Conflicts セクション（Phase 4 の衝突があった場合）
- .gitignore 推奨メッセージ

### action-items.md

threat-model-template.md のフォーマットに従い、各アクションアイテムを以下のスキーマで記述:

```yaml
- id: ACTION-001
  threat_ref: THREAT-001
  title: "{対策タイトル}"
  description: "{対策の詳細}"
  risk_level: Critical|High|Medium|Low
  severity_score: {CVSS スコア}
  owner: ""
  due: P0|P1|P2|P3
  status: open
  acceptance_criteria: "{完了条件}"
  verification: "{検証方法}"
  evidence_link: ""
```

---

## Phase 7: クリーンアップ

1. SendMessage で black-hacker と white-hacker にシャットダウンリクエスト
2. 全エージェントのシャットダウン確認後、TeamDelete

---

## 完了報告

ユーザーに以下を報告:
- 検出された脅威の数（深刻度別）
- 策定された対策の数（優先度別）
- Conflicts の有無（ある場合はユーザー判断を依頼）
- 生成されたファイル一覧
- `.gitignore` 推奨メッセージ
- 次のステップ:
  ```
  対策を実装タスクに変換するには:
  /kairo-tasks docs/security/{target-name}/action-items.md
  ```
- 保存期間の確認:
  ```
  セキュリティレビュー出力の保存期間はデフォルト90日です。
  docs/security/{target-name}/ の削除タイミングを確認してください。
  ```
