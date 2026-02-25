# カテゴリ判定ルール（first-match rule）

このファイルは調査トピックを3つのカテゴリに分類するロジックを定義する。
**上から順にチェックし、最初にマッチしたルールを適用する（first-match rule）。**

---

## 判定フロー（決定木）

```
入力: トピック・ユーザーの発言
         │
         ▼
[1] 機密情報を含むか？
    YES → 保存中断・ユーザーに警告（カテゴリなし）
    NO  →
         │
         ▼
[2] URL が明示指定されているか？
    YES → 【Clippings/】 confidence: HIGH
    NO  →
         │
         ▼
[3] 「〇〇とは？」「〇〇の定義」「〇〇の仕組み」が明示的か？
    かつ、IT/技術/プログラミング関連キーワードを含むか？
    YES → 【IT用語集/】 confidence: HIGH（出典2件以上なら verified）
    NO  →
         │
         ▼
[4] IT/技術関連だがトレンド・比較・まとめ系の発言か？
    YES → 【調査メモ/】 confidence: MEDIUM（status: draft）
    NO  →
         │
         ▼
[5] 上記いずれにも当てはまらない（fallback）
    → 【調査メモ/】 confidence: LOW（status: draft）
```

---

## IT/技術関連キーワード例

以下のキーワードが含まれる場合は技術系として判定する:

**プログラミング言語・フレームワーク**:
- Python, JavaScript, TypeScript, Rust, Go, Java, C++, Swift, Kotlin
- React, Vue, Angular, Next.js, Nuxt, Svelte, Express, FastAPI, Django
- Node.js, Deno, Bun, Rails

**インフラ・クラウド**:
- AWS, GCP, Azure, Docker, Kubernetes, k8s, Terraform, Ansible
- Linux, Ubuntu, macOS, nginx, Apache, Nginx
- CI/CD, GitHub Actions, Jenkins

**AI/ML**:
- LLM, GPT, Claude, Gemini, RAG, fine-tuning, embedding
- PyTorch, TensorFlow, scikit-learn, Hugging Face
- 機械学習, 深層学習, ニューラルネットワーク, トランスフォーマー

**データベース**:
- PostgreSQL, MySQL, SQLite, MongoDB, Redis, Elasticsearch
- SQL, NoSQL, ORM, マイグレーション

**開発ツール・概念**:
- Git, GitHub, GitLab, PR, プルリクエスト
- API, REST, GraphQL, gRPC, WebSocket
- TDD, CI/CD, DevOps, SRE, アジャイル, スクラム
- tmux, vim, neovim, zsh, bash, shell

**その他 IT 用語**:
- CDN, DNS, HTTP, HTTPS, TCP/IP, SSL/TLS
- 暗号化, 認証, 認可, JWT, OAuth
- コンパイラ, インタープリタ, バイトコード
- アルゴリズム, データ構造, 計算量, O記法

---

## 「〇〇とは」「〇〇の定義」判定キーワード

以下のいずれかが含まれる場合は IT用語集 候補として強く評価する:

- 「〇〇とは」「〇〇とは何か」「〇〇とは？」
- 「〇〇の定義」「〇〇を定義して」
- 「〇〇の仕組み」「〇〇はどのように動く」
- 「〇〇の概念」「〇〇について説明して」
- 「〇〇を教えて」（IT用語キーワードと組み合わさる場合）

---

## トレンド・まとめ系キーワード（調査メモ候補）

以下が含まれる場合は調査メモとして判定する:

- 「最近の〇〇」「〇〇のトレンド」「〇〇の動向」
- 「〇〇を比較して」「〇〇 vs 〇〇」「〇〇の違い」
- 「〇〇のまとめ」「〇〇について調べて」（定義系でない）
- 「〇〇のメリット・デメリット」「〇〇の使い所」

---

## 判定例（正例・誤例）

※ `status` は SKILL.md の一元定義で決まるため、ここでは保存先（カテゴリ）のみ示す。

| 入力 | 判定 | 保存先 |
|-----|------|--------|
| 「LLMとは何か」 | HIGH | IT用語集/LLM.md |
| 「React Hooksについて調べて」 | HIGH | IT用語集/React Hooks.md |
| 「https://example.com を保存して」 | HIGH | Clippings/ |
| 「最近のAIトレンドをまとめて」 | MEDIUM | 調査メモ/ |
| 「tmuxとvimの違いを教えて」 | MEDIUM | 調査メモ/ |
| 「好きな食べ物について調べて」 | LOW | 調査メモ/ |
| 「このAPIキーの仕組みを調べて」 | - | 機密検知で保存中断 |
| 「社外秘の設計書をまとめて」 | - | 機密検知で保存中断 |

---

## confidence 閾値まとめ

**このファイルは「カテゴリ（保存先）」のみを決定する。`status` の決定は SKILL.md の「status 決定ルール（一元定義）」に委ねる。**

| confidence | 条件 | 保存先 |
|-----------|-----|--------|
| HIGH | first-match で明確なカテゴリに合致 | IT用語集/ または Clippings/ |
| MEDIUM | first-match で判定可能・トレンド系 | 対応カテゴリ（主に 調査メモ/） |
| LOW | fallback（どのルールにも当てはまらない）| 調査メモ/ |

---

## fallback ルール

- どのルールにもマッチしない場合は **必ず `調査メモ/` に保存**する
- `status: draft` を付与する
- ファイル名は `{YYYY-MM-DD}-{トピック}.md` 形式
- 保存後にユーザーへ「カテゴリ判定が低信頼のため調査メモに保存しました」と通知する
