# Security Review スキル — 詳細手順

> 授権されたセキュリティ作業の思考支援ツール。
> Black Hacker（攻撃者視点）と White Hacker（防衛者視点）の双子エージェントによる包括的セキュリティレビューを提供する。

---

## クイックスタート

| コマンド | 用途 | モード |
|---------|------|--------|
| `/sec-black` | 攻撃者視点の脅威分析（単体） | 軽量・素早いレビュー |
| `/sec-white` | 防衛者視点の対策立案（単体） | 脅威モデル読み込み後 |
| `/sec-review` | 双子エージェント統合レビュー | チームモード（TeamCreate） |

## 設計思想

### Hybrid 方式

1. **並列独立分析**（Phase 3）: black / white が互いの出力を見ずに独立分析 → anchoring bias 防止
2. **逐次統合**（Phase 4）: 出力を交換して相互補完 → 漏れを低減
3. **Debate**（Phase 5）: デフォルト ON。1ラウンド上限で対策の穴を検証

### Authorization Gate

全コマンド共通で **ethics.md の Authorization Gate** を通過しない限り実行不可（hard fail）。

---

## ファイル索引

| ファイル | 役割 |
|---------|------|
| `SKILL.md` | 概要（軽量） |
| `INSTRUCTIONS.md` | 本ファイル。詳細手順 |
| [`ethics.md`](./ethics.md) | 倫理的フレームワーク・Authorization Gate・禁止事項・スコープ外判定 |
| [`black-hacker.md`](./black-hacker.md) | 攻撃者視点フレームワーク（STRIDE / OWASP Top 10） |
| [`white-hacker.md`](./white-hacker.md) | 防衛者視点フレームワーク（Defense-in-Depth / NIST CSF） |
| [`threat-model-template.md`](./threat-model-template.md) | 出力フォーマット・ディレクトリ構造・機密分類ルール |

## コマンド索引

| コマンド | ファイル |
|---------|---------|
| `/sec-black` | `~/.config/.claude/commands/sec-black.md` |
| `/sec-white` | `~/.config/.claude/commands/sec-white.md` |
| `/sec-review` | `~/.config/.claude/commands/sec-review.md` |

## 出力先ディレクトリ

```
プロジェクトルート/
└── docs/security/{target-name}/
    ├── authorization-record.md   ← Phase 1: 監査証跡
    ├── threat-model.md           ← Phase 3: black-hacker 生成
    ├── independent-assessment.md ← Phase 3: white-hacker 独立分析
    ├── defense-strategy.md       ← Phase 4: white-hacker 統合生成
    ├── review-summary.md         ← Phase 6: 統合レポート
    └── action-items.md           ← Phase 6: kairo-tasks 連携用
```

## 連携フロー

```
/sec-review → action-items.md
    ↓ (授権済み対策の実装フロー)
/kairo-tasks → /kairo-implement (対策実装タスク化)
    ↓ (TDD で実装)
/tdd-requirements → /tdd-red → /tdd-green → /tdd-refactor
```

## 機密分類（4段階）

| レベル | 用途 |
|--------|------|
| PUBLIC | 教育目的サマリー |
| **INTERNAL** | チーム内共有（デフォルト） |
| CONFIDENTIAL | 脆弱性詳細。認証情報は `[REDACTED]` |
| RESTRICTED | Critical 脅威。アクセス制限必須 |

詳細は [`ethics.md`](./ethics.md) の「データ分類と出力制約」セクションを参照。
