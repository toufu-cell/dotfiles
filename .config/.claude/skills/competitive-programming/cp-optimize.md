# 競技プログラミング最適化スキル

TLE (Time Limit Exceeded) や MLE (Memory Limit Exceeded) を解消するための最適化を行います。

## 目的

- 計算量の削減
- メモリ使用量の最適化
- 定数倍高速化
- 言語固有の最適化

## 問題情報

**【現在のコード】**: {{current_code}}
**【発生している問題】**: {{issue_type}} (TLE / MLE / 部分点のみ)
**【使用言語】**: {{language}}
**【現在の計算量】**: {{current_complexity}}

## 最適化チェックリスト

### Phase 1: アルゴリズム改善 (計算量削減)

```
【現状分析】:
- 現在の時間計算量: O(?)
- 現在の空間計算量: O(?)
- ボトルネック箇所: [特定した箇所]

【改善候補】:
□ より効率的なアルゴリズムへの変更
  - [具体的な改善案]
□ データ構造の変更
  - [配列 → ハッシュ, リスト → set 等]
□ 前処理の追加
  - [累積和, ソート, 座標圧縮 等]
□ 枝刈りの追加
  - [探索の早期打ち切り条件]
□ 計算の省略
  - [メモ化, 重複計算の排除]
```

### Phase 2: 言語固有の最適化

#### Python 最適化

```python
# 【入出力高速化】
import sys
input = sys.stdin.readline
print = sys.stdout.write  # 文字列のみ

# 【PyPyの利用】(AtCoderで利用可能)
# - CPythonより10〜100倍高速
# - 再帰の深さ制限に注意

# 【リスト内包表記】
# Bad: 遅い
result = []
for i in range(N):
    result.append(i * 2)

# Good: 高速
result = [i * 2 for i in range(N)]

# 【ローカル変数化】
# グローバル変数より高速
def solve():
    local_func = global_func  # ローカルにキャッシュ
    for i in range(N):
        local_func(i)

# 【collections.deque】
# リストの先頭操作は O(N), dequeは O(1)
from collections import deque
q = deque()
q.appendleft(x)  # O(1)
q.popleft()      # O(1)

# 【bisectモジュール】
from bisect import bisect_left, bisect_right, insort

# 【再帰上限の設定】
sys.setrecursionlimit(10**6)

# 【@lru_cache でメモ化】
from functools import lru_cache

@lru_cache(maxsize=None)
def dp(i, j):
    # 再帰的なDP
    pass
```

#### JavaScript 最適化

```javascript
// 【paiza用 readline テンプレート】
process.stdin.resume();
process.stdin.setEncoding('utf8');

var lines = [];
var reader = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

reader.on('line', function(line) {
    lines.push(line);
});

reader.on('close', function() {
    solve();
});

function solve() {
    // 処理を書く
}

// 【配列の事前確保】
// Bad: 動的拡張
var arr = [];
for (var i = 0; i < N; i++) arr.push(i);

// Good: 事前確保
var arr = new Array(N);
for (var i = 0; i < N; i++) arr[i] = i;

// 【TypedArray の利用】
// 数値配列で高速
var arr = new Int32Array(N);  // 32bit整数
var arr = new Float64Array(N);  // 64bit浮動小数点

// 【Map/Set の活用】
// Object より高速なキー検索
var map = new Map();
var set = new Set();

// 【ビット演算】
// 除算・剰余より高速
var half = n >> 1;           // n / 2
var isOdd = n & 1;          // n % 2
var double = n << 1;        // n * 2

// 【配列のコピー】
// スプレッド演算子より slice が速い
var copy = arr.slice();

// 【文字列結合】
// 配列に push して最後に join
var parts = [];
for (var i = 0; i < N; i++) {
    parts.push(result[i]);
}
console.log(parts.join('\n'));

// 【BigInt 使用時の注意】
// 通常の Number より遅い
// 必要な箇所のみ BigInt を使用
```

### Phase 3: メモリ最適化 (MLE対策)

```
【メモリ削減戦略】:

□ 不要なデータの削除
  - 使い終わった配列の解放
  - スコープを限定してGC対象に

□ データ型の最適化
  - JavaScript: TypedArray の活用
  - Python: array モジュールの検討

□ 配列サイズの最適化
  - 必要最小限のサイズに
  - 座標圧縮で範囲を削減

□ インプレース処理
  - 新しい配列を作らず上書き
  - スワップで要素交換

□ DP配列の次元削減
  - dp[i][j] → dp[j] (前の行のみ必要な場合)
  - 配り方DP → 貰い方DP への変換

□ ビット演算
  - bool配列 → ビットセット
  - 状態圧縮DP
```

### Phase 4: 定数倍高速化

```
【定数倍改善】:

□ ループの最適化
  - 内側ループの処理を軽量化
  - ループ変数のキャッシュ

□ 条件分岐の削減
  - 三項演算子の活用
  - ブランチレス処理

□ キャッシュ効率
  - メモリアクセスパターンの改善
  - 連続メモリアクセス

□ 演算の簡略化
  - 除算 → 乗算への変換
  - べき乗 → ビットシフト
```

## 最適化適用例

### 例1: 二重ループ → 累積和

```python
# Before: O(N^2)
for i in range(N):
    total = sum(A[i:j+1])  # 毎回計算

# After: O(N)
# 累積和を前処理
prefix = [0] * (N + 1)
for i in range(N):
    prefix[i+1] = prefix[i] + A[i]

# 区間和を O(1) で取得
total = prefix[j+1] - prefix[i]
```

### 例2: 探索 → 二分探索

```python
# Before: O(N)
for x in A:
    if x == target:
        return True

# After: O(log N)
A.sort()  # ソート済みが前提
idx = bisect_left(A, target)
return idx < len(A) and A[idx] == target
```

### 例3: DP配列の次元削減

```python
# Before: O(N*W) 空間
dp = [[0] * (W+1) for _ in range(N+1)]
for i in range(N):
    for w in range(W+1):
        dp[i+1][w] = max(dp[i][w], dp[i][w-cost[i]] + value[i])

# After: O(W) 空間
dp = [0] * (W+1)
for i in range(N):
    for w in range(W, cost[i]-1, -1):  # 逆順！
        dp[w] = max(dp[w], dp[w-cost[i]] + value[i])
```

### 例4: JavaScript での最適化

```javascript
// Before: 遅い
var result = '';
for (var i = 0; i < N; i++) {
    result += arr[i] + '\n';
}
console.log(result);

// After: 高速
console.log(arr.join('\n'));
```

```javascript
// Before: 動的配列拡張
var dp = [];
for (var i = 0; i < N; i++) {
    dp.push(new Array(M).fill(0));
}

// After: 事前確保
var dp = [];
for (var i = 0; i < N; i++) {
    dp.push(new Int32Array(M));
}
```

## 出力形式

1. **問題診断**: TLE/MLEの原因分析
2. **最適化戦略**: 適用する最適化手法
3. **最適化後コード**: 改善されたコード
4. **改善効果**: 計算量/メモリ使用量の改善度
5. **検証結果**: サンプルケースでの動作確認

## 品質基準

```
✅ 最適化成功:
- 時間制限内に収まる
- メモリ制限内に収まる
- 正解を維持

⚠️ 追加対応必要:
- まだTLE/MLEが発生
- 一部ケースで不正解
- さらなる最適化余地あり
```

## 次のステップ

- 最適化成功の場合: 提出して結果確認
- さらに分析が必要な場合: `/cp-analyze` で別解を検討
