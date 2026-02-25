# 競技プログラミング問題解答スキル

競技プログラミングの問題を解析し、最適なアルゴリズムでコードを生成します。

## 対応プラットフォーム

- **paiza**: レベル S, A, B, C, D
- **AtCoder**: ABC, ARC, AGC（灰〜赤難易度）
- **その他**: LeetCode, Codeforces, yukicoder

## 問題情報

**【問題URL/出典】**: {{problem_source}}
**【難易度】**: {{difficulty}} (例: AtCoder ABC-C, paiza-B)
**【使用言語】**: {{language}} (Python / JavaScript)

## 実行フロー

### Phase 1: 問題文解析

問題文を以下の形式で構造化します:

#### 入力形式

```
【入力変数】:
- 変数名: [型] [制約範囲] [意味]
- N: int, 1 <= N <= 10^5, 配列の要素数
- ...

【入力例】:
（問題文のサンプル入力をそのまま記載）
```

#### 出力形式

```
【出力形式】: [期待される出力の説明]
【出力例】: （問題文のサンプル出力をそのまま記載）
```

#### 問題の要約

```
【問題タイプ】: [探索/DP/グラフ/数学/文字列/etc]
【求めるもの】: [最大値/最小値/個数/判定/etc]
【制約のポイント】: [計算量に影響する主要な制約]
```

### Phase 2: 計算量分析

```
【目標計算量】: O(?) [制約から逆算]
- N = 10^5 の場合 → O(N log N) 以下が目安
- N = 10^6 の場合 → O(N) が必要
- N = 10^3 の場合 → O(N^2) でも可

【空間計算量】: O(?)
- メモリ制限: 通常 256MB〜1024MB
- 配列サイズの見積もり: [計算]
```

### Phase 3: アルゴリズム選定

以下の観点でアルゴリズムを選択:

```
【候補アルゴリズム】:
1. [アルゴリズム名] - O(?) - [適用条件/メリット]
2. [アルゴリズム名] - O(?) - [適用条件/メリット]

【選定結果】: [選んだアルゴリズム]
【選定理由】: [なぜこのアルゴリズムが最適か]
```

#### 典型アルゴリズムチェックリスト

- [ ] 全探索 (N <= 10^6)
- [ ] 二分探索 (ソート済み/単調性)
- [ ] 累積和/いもす法 (区間処理)
- [ ] 動的計画法 (最適化/数え上げ)
- [ ] グラフ探索 (BFS/DFS)
- [ ] 最短経路 (Dijkstra/Bellman-Ford)
- [ ] Union-Find (連結成分)
- [ ] セグメント木/BIT (区間クエリ)
- [ ] 貪欲法 (局所最適)
- [ ] 数学的解法 (GCD/素数/組合せ)

### Phase 4: コード実装

#### Python テンプレート

```python
import sys
from collections import defaultdict, deque
from heapq import heappush, heappop
from bisect import bisect_left, bisect_right
from itertools import permutations, combinations
from functools import lru_cache

# 高速入力
input = sys.stdin.readline

def solve():
    # 【入力処理】: 問題の入力形式に合わせて読み取り
    N = int(input())
    A = list(map(int, input().split()))

    # 【メイン処理】: アルゴリズムの実装
    # ...

    # 【出力処理】: 結果の出力
    print(result)

if __name__ == "__main__":
    solve()
```

#### JavaScript テンプレート (Node.js ES6+)

**重要**: JavaScript では必ず ES6+ のモダンな書き方を使用すること。

```javascript
// paiza/AtCoder共通: readline形式（ES6+）
process.stdin.resume();
process.stdin.setEncoding('utf8');

const lines = [];
const reader = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

reader.on('line', (line) => {
    lines.push(line);
});

reader.on('close', () => {
    solve();
});

function solve() {
    let lineIndex = 0;
    const readLine = () => lines[lineIndex++];

    // 【入力処理】- 分割代入を活用
    const N = Number(readLine());
    const [N, M] = readLine().split(' ').map(Number);  // 複数値
    const A = readLine().split(' ').map(Number);       // 配列

    // 【配列初期化】- Array.from / fill を使用
    const visited = new Array(N).fill(false);
    const dist = new Array(N).fill(-1);
    const graph = Array.from({ length: N }, () => []);

    // 【メイン処理】- 高階関数を活用
    let result = 0;

    // 条件判定
    const hasMatch = A.some((x) => x > 0);
    const allPositive = A.every((x) => x > 0);

    // 合計・最大・最小
    const sum = A.reduce((acc, x) => acc + x, 0);
    const max = Math.max(...A);
    const min = Math.min(...A);

    // フィルタリング・変換
    const filtered = A.filter((x) => x > 0);
    const doubled = A.map((x) => x * 2);

    // 【出力処理】
    console.log(result);
}
```

**避けるべき書き方**:
- ❌ `var` → ✅ `const` / `let`
- ❌ `function(x) {}` → ✅ `(x) => {}`
- ❌ `for (var i = 0; ...)` でのpush → ✅ `Array.from({ length: N }, ...)`
- ❌ `parseInt(parts[0]); parseInt(parts[1]);` → ✅ `const [a, b] = line.split(' ').map(Number)`

### Phase 5: テスト検証

```
【サンプルケース検証】:
- ケース1: 入力 → 期待出力 → 実際の出力 → [OK/NG]
- ケース2: 入力 → 期待出力 → 実際の出力 → [OK/NG]
- ケース3: 入力 → 期待出力 → 実際の出力 → [OK/NG]

【エッジケース確認】:
- 最小入力 (N=1 など)
- 最大入力 (制約上限)
- 境界値
- 全て同じ値
- 昇順/降順ソート済み

【計算量確認】:
- 最大ケースでの実行時間見積もり: [計算]
- メモリ使用量見積もり: [計算]
```

## 提供物

1. **問題分析**: 構造化された問題の理解
2. **アルゴリズム選定理由**: なぜその解法を選んだか
3. **完全なソースコード**: 日本語コメント付き
4. **計算量**: 時間・空間計算量の明示
5. **テスト結果**: サンプルケースの検証結果

## 品質基準

```
✅ 高品質:
- サンプルケース: 全て通過
- 計算量: 制約を満たす
- コード: 読みやすく保守可能
- エッジケース: 考慮済み

⚠️ 要改善:
- サンプルケース不通過
- TLE/MLE リスクあり
- コードが複雑
- エッジケース未考慮
```

## 次のステップ

- 最適化が必要な場合: `/cp-optimize` で TLE/MLE 対策
- 別解を検討したい場合: `/cp-analyze` で詳細分析
