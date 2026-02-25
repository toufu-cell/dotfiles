# Security Review — 出力テンプレート・ディレクトリ構造

> セキュリティレビューの出力ファイル仕様とフォーマットを定義する。

---

## 出力ディレクトリ構造

```
プロジェクトルート/
└── docs/security/{target-name}/
    ├── authorization-record.md   ← Phase 1: Authorization Gate 監査証跡
    ├── threat-model.md           ← Phase 3: black-hacker 生成（攻撃者視点分析）
    ├── independent-assessment.md ← Phase 3: white-hacker 独立分析
    ├── defense-strategy.md       ← Phase 4: white-hacker 統合対策
    ├── review-summary.md         ← Phase 6: 統合レポート
    └── action-items.md           ← Phase 6: kairo-tasks 連携用
```

- `{target-name}`: レビュー対象の識別名（kebab-case）
- ディレクトリが存在しない場合は自動作成

---

## 機密分類ヘッダ

すべての出力ファイルの **先頭行** に以下のヘッダを付与する:

```markdown
<!-- classification: {LEVEL} -->
```

### 各ファイルのデフォルト分類

| ファイル | デフォルト分類 | 理由 |
|---------|-------------|------|
| `authorization-record.md` | CONFIDENTIAL | 認証・許可情報を含む |
| `threat-model.md` | CONFIDENTIAL | 具体的な脆弱性詳細を含む |
| `independent-assessment.md` | INTERNAL | 防御態勢の評価 |
| `defense-strategy.md` | INTERNAL | 対策方針（脆弱性詳細は参照のみ） |
| `review-summary.md` | INTERNAL | 統合サマリー |
| `action-items.md` | INTERNAL | 対策タスク一覧 |

ユーザーが Authorization Gate で指定した分類レベルが上記より高い場合、全ファイルをその分類に引き上げる。

---

## ファイルテンプレート

### authorization-record.md

```markdown
<!-- classification: CONFIDENTIAL -->
# Authorization Record — {target-name}

> セキュリティレビューの授権記録。改ざん検知用ハッシュを含む。

## 授権情報

| 項目 | 値 |
|------|-----|
| 対象 | {target-name} |
| スコープ | {テスト範囲の説明} |
| 期間 | {開始日} — {終了日} |
| 承認者 | {氏名} |
| 許可ID | {ID（任意）} |
| 分類レベル | {PUBLIC/INTERNAL/CONFIDENTIAL/RESTRICTED} |
| 報告先 | {報告先} |
| 禁止行為同意 | Yes |
| 記録日時 | {ISO 8601} |
| 保存期間 | 90日 |

## 整合性検証

```yaml
sha256: "{authorization セクションの SHA-256 ハッシュ}"
```

> このハッシュは授権情報の改ざん検知に使用されます。
> 授権情報を変更した場合は、ハッシュを再計算してください。
```

### threat-model.md

```markdown
<!-- classification: CONFIDENTIAL -->
# Threat Model — {target-name}

> 攻撃者視点の脅威分析。black-hacker による独立分析結果。

## 対象概要

- **システム名**: {target-name}
- **分析スコープ**: {スコープの説明}
- **分析日**: {日付}

## 資産一覧

| ID | 資産名 | 機密性 | 説明 |
|----|--------|--------|------|
| ASSET-001 | ... | High/Medium/Low | ... |

## 信頼境界

{信頼境界の説明またはダイアグラム}

## 脅威一覧

### THREAT-001: {脅威名}

- **STRIDE カテゴリ**: {S/T/R/I/D/E}
- **OWASP カテゴリ**: {A01-A10}
- **CWE**: CWE-{番号} — {名前}
- **対象コンポーネント**: {ファイルパス:行番号 or モジュール名}
- **攻撃ベクトル**: {概念的な攻撃経路の説明}
- **前提条件**: {攻撃に必要な条件}
- **影響**:
  - 機密性: {High/Medium/Low/None}
  - 完全性: {High/Medium/Low/None}
  - 可用性: {High/Medium/Low/None}
- **CVSS v3 ベーススコア**: {0.0-10.0}（概算）
- **深刻度**: {Critical/High/Medium/Low}
- **シナリオ**: {攻撃シナリオの概念的説明}
- **証拠**: {コード内の該当箇所の引用・説明}

## サマリー

| 深刻度 | 件数 |
|--------|------|
| Critical | N |
| High | N |
| Medium | N |
| Low | N |

---

## v1 Freeze Record
- frozen_at: {ISO 8601}
- threat_count: {N}
- cross_reference: none (independent analysis)

## Phase 4 Amendments
{Phase 4 で追記された内容（ある場合）}
```

### independent-assessment.md

```markdown
<!-- classification: INTERNAL -->
# Independent Security Assessment — {target-name}

> 防衛者視点の独立分析結果。white-hacker による独立評価。
> threat-model.md を参照せずに作成。

## 対象概要

- **システム名**: {target-name}
- **分析スコープ**: {スコープの説明}
- **分析日**: {日付}

## Defense-in-Depth 評価

| 層 | 現状 | 充足度 |
|----|------|--------|
| L1: 境界防御 | ... | 十分/部分的/不足/なし |
| L2: アプリケーション層 | ... | ... |
| L3: データ層 | ... | ... |
| L4: 監視・対応 | ... | ... |

## NIST CSF 評価

| 機能 | 現状 | 充足度 |
|------|------|--------|
| Identify | ... | ... |
| Protect | ... | ... |
| Detect | ... | ... |
| Respond | ... | ... |
| Recover | ... | ... |

## 評価詳細

### ASSESSMENT-001: {評価項目名}

- **NIST CSF 機能**: {Identify/Protect/Detect/Respond/Recover}
- **Defense-in-Depth 層**: {L1/L2/L3/L4}
- **現状**: {現在の対策状況の説明}
- **充足度**: {十分/部分的/不足/なし}
- **ギャップ**: {不足している対策の説明}
- **推奨対策**: {独立分析に基づく対策案}
- **対象コンポーネント**: {ファイルパス:行番号 or モジュール名}

---

## v1 Freeze Record
- frozen_at: {ISO 8601}
- assessment_count: {N}
- cross_reference: none (independent analysis)
```

### defense-strategy.md

```markdown
<!-- classification: INTERNAL -->
# Defense Strategy — {target-name}

> threat-model.md と independent-assessment.md を統合した防御戦略。

## 対策サマリー

| 優先度 | 件数 | 対応期間 |
|--------|------|---------|
| P0 (緊急) | N | 即日 |
| P1 (Quick Win) | N | 1-3日 |
| P2 (短期) | N | 1-2週間 |
| P3 (長期) | N | 1ヶ月以上 |

## 対策詳細

### DEFENSE-001: {対策名}

- **対応脅威**: THREAT-{N}
- **Defense-in-Depth 層**: {L1/L2/L3/L4}
- **NIST CSF 機能**: {Identify/Protect/Detect/Respond/Recover}
- **優先度**: {P0/P1/P2/P3}
- **現状の防御**: {既存対策の有無と評価}
- **推奨対策**:
  - 概要: {対策の説明}
  - 実装方針: {具体的な実装アプローチ}
  - 対象ファイル: {修正が必要なファイルパス}
- **残留リスク**: {対策実施後に残るリスク}
- **検証方法**: {対策の有効性を確認する方法}

## 残留リスク

| リスク | 理由 | 受容判断 |
|--------|------|---------|
| ... | ... | 受容/要追加対策/要ユーザー判断 |
```

### review-summary.md

```markdown
<!-- classification: INTERNAL -->
# Security Review Summary — {target-name}

> セキュリティレビューの統合サマリー。

## レビュー概要

| 項目 | 値 |
|------|-----|
| 対象 | {target-name} |
| レビュー日 | {日付} |
| 分類レベル | {LEVEL} |
| 脅威検出数 | {N} |
| 対策提案数 | {N} |

## 脅威サマリー

| 深刻度 | 件数 | 対策済み | 未対策 |
|--------|------|---------|-------|
| Critical | N | N | N |
| High | N | N | N |
| Medium | N | N | N |
| Low | N | N | N |

## 主要な発見事項

1. {最も深刻度の高い脅威の概要}
2. ...

## 推奨アクション（優先順）

1. {P0 の対策}
2. {P1 の対策}
3. ...

## Conflicts

> Phase 4 で black/white の評価が衝突した項目。
> 最終判断はユーザーに委ねる（自動マージしない）。

| 項目 | Black の評価 | White の評価 | 採用（conservative） | 根拠 |
|------|-------------|-------------|---------------------|------|
| ... | ... | ... | ... | ... |

## .gitignore 推奨

⚠️ `docs/security/` を `.gitignore` に追加することを推奨します。
機密性の高い脆弱性情報がリポジトリに含まれるリスクを軽減できます。
```

### action-items.md

```markdown
<!-- classification: INTERNAL -->
# Action Items — {target-name}

> kairo-tasks 連携用のアクションアイテム一覧。
> `/kairo-tasks` に渡して対策実装タスクを生成する。

## アクションアイテム

- id: ACTION-001
  threat_ref: THREAT-001
  title: "{対策タイトル}"
  description: "{対策の詳細説明}"
  risk_level: Critical|High|Medium|Low
  severity_score: 9.1
  owner: ""
  due: P0|P1|P2|P3
  status: open
  acceptance_criteria: "{完了条件}"
  verification: "{検証方法}"
  evidence_link: ""

## 使い方

このファイルを `/kairo-tasks` に渡すことで、
対策実装タスクを自動的にタスク分割できます:

```
/kairo-tasks docs/security/{target-name}/action-items.md
```
```

---

## Secret Redaction ルール

出力ファイル生成時に以下の情報は `[REDACTED]` に置換する:

| 対象 | 例 |
|------|-----|
| API キー | `Authorization: Bearer [REDACTED]` |
| パスワード | `password: [REDACTED]` |
| トークン | `token: [REDACTED]` |
| 接続文字列 | `DATABASE_URL=[REDACTED]` |
| 内部 URL | `https://[REDACTED]/api/v1/...` |
| PII | `email: [REDACTED]` |

---

## ファイル生成順序

```
Phase 1: authorization-record.md
Phase 3: threat-model.md, independent-assessment.md（並列）
Phase 4: defense-strategy.md
Phase 6: review-summary.md, action-items.md
```
