# 競技プログラミング テンプレート集

頻出パターンのテンプレートコードを提供します。

## 言語選択

**【使用言語】**: {{language}}

---

## 入出力テンプレート

### Python

```python
# === 高速入出力 ===
import sys
input = sys.stdin.readline
sys.setrecursionlimit(10**6)

# === 基本入力パターン ===

# 1つの整数
N = int(input())

# 複数の整数（1行）
N, M = map(int, input().split())

# 配列（1行）
A = list(map(int, input().split()))

# 複数行の配列
A = [int(input()) for _ in range(N)]

# 2次元配列
grid = [list(map(int, input().split())) for _ in range(H)]

# 文字列
S = input().strip()

# 文字列の配列
S = list(input().strip())

# グラフ（隣接リスト）
G = [[] for _ in range(N+1)]
for _ in range(M):
    a, b = map(int, input().split())
    G[a].append(b)
    G[b].append(a)  # 無向グラフの場合

# === 出力パターン ===

# 1つの値
print(ans)

# 配列（スペース区切り）
print(*A)
# または
print(' '.join(map(str, A)))

# 配列（改行区切り）
print('\n'.join(map(str, A)))

# Yes/No判定
print("Yes" if condition else "No")

# 小数点以下指定
print(f"{ans:.10f}")
```

### JavaScript (Node.js) - ES6+

```javascript
// === paiza用: readline形式 (ES6+) ===
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

    // === 基本入力パターン ===

    // 1つの整数
    const N = Number(readLine());

    // 複数の整数（1行）- 分割代入
    const [N, M] = readLine().split(' ').map(Number);

    // 配列（1行）
    const A = readLine().split(' ').map(Number);

    // 複数行の配列
    const A = Array.from({ length: N }, () => Number(readLine()));

    // 2次元配列
    const grid = Array.from({ length: H }, () => readLine().split(' ').map(Number));

    // 文字列
    const S = readLine();

    // 文字列を配列に
    const chars = [...readLine()];

    // グラフ（隣接リスト）
    const G = Array.from({ length: N + 1 }, () => []);
    for (let i = 0; i < M; i++) {
        const [a, b] = readLine().split(' ').map(Number);
        G[a].push(b);
        G[b].push(a);  // 無向グラフの場合
    }

    // === 配列初期化パターン ===

    // 固定値で初期化
    const arr = new Array(N).fill(0);
    const bools = new Array(N).fill(false);

    // インデックス値で初期化
    const indices = Array.from({ length: N }, (_, i) => i);

    // 2次元配列の初期化
    const grid2D = Array.from({ length: H }, () => new Array(W).fill(0));

    // === 出力パターン ===

    // 1つの値
    console.log(ans);

    // 配列（スペース区切り）
    console.log(A.join(' '));

    // 配列（改行区切り）
    console.log(A.join('\n'));

    // Yes/No判定
    console.log(condition ? "Yes" : "No");

    // 小数点以下指定
    console.log(ans.toFixed(10));

    // === 便利なイディオム ===

    // 条件を満たす要素があるか
    const hasMatch = arr.some((x) => x > 0);

    // 全ての要素が条件を満たすか
    const allMatch = arr.every((x) => x > 0);

    // 条件を満たす要素を抽出
    const filtered = arr.filter((x) => x > 0);

    // 合計
    const sum = arr.reduce((acc, x) => acc + x, 0);

    // 最大・最小
    const max = Math.max(...arr);
    const min = Math.min(...arr);

    // ユニークな値
    const unique = [...new Set(arr)];

    // ソート（数値）
    arr.sort((a, b) => a - b);  // 昇順
    arr.sort((a, b) => b - a);  // 降順
}
```

---

## アルゴリズムテンプレート

### 二分探索

#### Python

```python
# === めぐる式二分探索 ===
def binary_search(ok, ng, check):
    """
    check(mid) が True となる境界を探す
    ok: 条件を満たす初期値
    ng: 条件を満たさない初期値
    """
    while abs(ok - ng) > 1:
        mid = (ok + ng) // 2
        if check(mid):
            ok = mid
        else:
            ng = mid
    return ok

# 使用例: x以上の最小値のインデックス
def check(mid):
    return A[mid] >= x

idx = binary_search(-1, N, check)
```

#### JavaScript

```javascript
// === めぐる式二分探索 ===
function binarySearch(ok, ng, check) {
    while (Math.abs(ok - ng) > 1) {
        const mid = Math.floor((ok + ng) / 2);
        if (check(mid)) {
            ok = mid;
        } else {
            ng = mid;
        }
    }
    return ok;
}

// 使用例
const check = (mid) => A[mid] >= x;
const idx = binarySearch(-1, N, check);
```

### Union-Find

#### Python

```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        self.size[rx] += self.size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def same(self, x, y):
        return self.find(x) == self.find(y)

    def get_size(self, x):
        return self.size[self.find(x)]
```

#### JavaScript

```javascript
class UnionFind {
    constructor(n) {
        this.parent = Array.from({ length: n }, (_, i) => i);
        this.rank = new Array(n).fill(0);
        this.size = new Array(n).fill(1);
    }

    find(x) {
        if (this.parent[x] !== x) {
            this.parent[x] = this.find(this.parent[x]);
        }
        return this.parent[x];
    }

    union(x, y) {
        let rx = this.find(x);
        let ry = this.find(y);
        if (rx === ry) return false;
        if (this.rank[rx] < this.rank[ry]) [rx, ry] = [ry, rx];
        this.parent[ry] = rx;
        this.size[rx] += this.size[ry];
        if (this.rank[rx] === this.rank[ry]) this.rank[rx]++;
        return true;
    }

    same(x, y) {
        return this.find(x) === this.find(y);
    }

    getSize(x) {
        return this.size[this.find(x)];
    }
}
```

### BFS/DFS

#### Python

```python
from collections import deque

# === BFS (最短距離) ===
def bfs(start, G, N):
    dist = [-1] * N
    dist[start] = 0
    q = deque([start])

    while q:
        v = q.popleft()
        for nv in G[v]:
            if dist[nv] == -1:
                dist[nv] = dist[v] + 1
                q.append(nv)

    return dist

# === DFS (再帰) ===
def dfs(v, parent, G):
    for nv in G[v]:
        if nv != parent:
            dfs(nv, v, G)

# === DFS (スタック) ===
def dfs_stack(start, G, N):
    visited = [False] * N
    stack = [start]

    while stack:
        v = stack.pop()
        if visited[v]:
            continue
        visited[v] = True
        for nv in G[v]:
            if not visited[nv]:
                stack.append(nv)
```

#### JavaScript

```javascript
// === BFS (最短距離) ===
function bfs(start, G, N) {
    const dist = new Array(N).fill(-1);
    dist[start] = 0;
    const q = [start];
    let head = 0;

    while (head < q.length) {
        const v = q[head++];
        for (const nv of G[v]) {
            if (dist[nv] === -1) {
                dist[nv] = dist[v] + 1;
                q.push(nv);
            }
        }
    }

    return dist;
}

// === DFS (スタック) ===
function dfs(start, G, N) {
    const visited = new Array(N).fill(false);
    const stack = [start];

    while (stack.length > 0) {
        const v = stack.pop();
        if (visited[v]) continue;
        visited[v] = true;
        for (const nv of G[v]) {
            if (!visited[nv]) {
                stack.push(nv);
            }
        }
    }

    return visited;
}
```

### Dijkstra

#### Python

```python
import heapq

def dijkstra(start, G, N):
    """
    G[v] = [(cost, to), ...]
    """
    INF = float('inf')
    dist = [INF] * N
    dist[start] = 0
    pq = [(0, start)]  # (cost, node)

    while pq:
        d, v = heapq.heappop(pq)
        if d > dist[v]:
            continue
        for cost, nv in G[v]:
            nd = d + cost
            if nd < dist[nv]:
                dist[nv] = nd
                heapq.heappush(pq, (nd, nv))

    return dist
```

#### JavaScript

```javascript
// 優先度付きキュー（簡易実装）
class PriorityQueue {
    constructor() {
        this.heap = [];
    }

    push(val) {
        this.heap.push(val);
        this._bubbleUp(this.heap.length - 1);
    }

    pop() {
        if (this.heap.length === 0) return null;
        const min = this.heap[0];
        const last = this.heap.pop();
        if (this.heap.length > 0) {
            this.heap[0] = last;
            this._bubbleDown(0);
        }
        return min;
    }

    _bubbleUp(i) {
        while (i > 0) {
            const p = Math.floor((i - 1) / 2);
            if (this.heap[p][0] <= this.heap[i][0]) break;
            [this.heap[p], this.heap[i]] = [this.heap[i], this.heap[p]];
            i = p;
        }
    }

    _bubbleDown(i) {
        const n = this.heap.length;
        while (2 * i + 1 < n) {
            let j = 2 * i + 1;
            if (j + 1 < n && this.heap[j + 1][0] < this.heap[j][0]) j++;
            if (this.heap[i][0] <= this.heap[j][0]) break;
            [this.heap[i], this.heap[j]] = [this.heap[j], this.heap[i]];
            i = j;
        }
    }

    get length() {
        return this.heap.length;
    }
}

function dijkstra(start, G, N) {
    const INF = Infinity;
    const dist = new Array(N).fill(INF);
    dist[start] = 0;
    const pq = new PriorityQueue();
    pq.push([0, start]);

    while (pq.length > 0) {
        const [d, v] = pq.pop();
        if (d > dist[v]) continue;
        for (const [cost, nv] of G[v]) {
            const nd = d + cost;
            if (nd < dist[nv]) {
                dist[nv] = nd;
                pq.push([nd, nv]);
            }
        }
    }

    return dist;
}
```

### 累積和

#### Python

```python
# === 1次元累積和 ===
def prefix_sum(A):
    N = len(A)
    S = [0] * (N + 1)
    for i in range(N):
        S[i+1] = S[i] + A[i]
    return S

# 区間[l, r)の和
def range_sum(S, l, r):
    return S[r] - S[l]

# === 2次元累積和 ===
def prefix_sum_2d(A):
    H, W = len(A), len(A[0])
    S = [[0] * (W+1) for _ in range(H+1)]
    for i in range(H):
        for j in range(W):
            S[i+1][j+1] = S[i][j+1] + S[i+1][j] - S[i][j] + A[i][j]
    return S

# 矩形[r1, c1) ~ [r2, c2)の和
def rect_sum(S, r1, c1, r2, c2):
    return S[r2][c2] - S[r1][c2] - S[r2][c1] + S[r1][c1]
```

#### JavaScript

```javascript
// === 1次元累積和 ===
function prefixSum(A) {
    const N = A.length;
    const S = new Array(N + 1).fill(0);
    for (let i = 0; i < N; i++) {
        S[i + 1] = S[i] + A[i];
    }
    return S;
}

// 区間[l, r)の和
function rangeSum(S, l, r) {
    return S[r] - S[l];
}

// === 2次元累積和 ===
function prefixSum2D(A) {
    const H = A.length, W = A[0].length;
    const S = Array.from({ length: H + 1 }, () => new Array(W + 1).fill(0));
    for (let i = 0; i < H; i++) {
        for (let j = 0; j < W; j++) {
            S[i + 1][j + 1] = S[i][j + 1] + S[i + 1][j] - S[i][j] + A[i][j];
        }
    }
    return S;
}

// 矩形[r1, c1) ~ [r2, c2)の和
function rectSum(S, r1, c1, r2, c2) {
    return S[r2][c2] - S[r1][c2] - S[r2][c1] + S[r1][c1];
}
```

### 素数関連

#### Python

```python
# === エラトステネスの篩 ===
def sieve(n):
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n+1, i):
                is_prime[j] = False
    return is_prime

# === 素因数分解 ===
def factorize(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors

# === 約数列挙 ===
def divisors(n):
    divs = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
        i += 1
    return sorted(divs)
```

#### JavaScript

```javascript
// === エラトステネスの篩 ===
function sieve(n) {
    const isPrime = new Array(n + 1).fill(true);
    isPrime[0] = isPrime[1] = false;
    for (let i = 2; i * i <= n; i++) {
        if (isPrime[i]) {
            for (let j = i * i; j <= n; j += i) {
                isPrime[j] = false;
            }
        }
    }
    return isPrime;
}

// === 素因数分解 ===
function factorize(n) {
    const factors = [];
    let d = 2;
    while (d * d <= n) {
        while (n % d === 0) {
            factors.push(d);
            n = Math.floor(n / d);
        }
        d++;
    }
    if (n > 1) factors.push(n);
    return factors;
}

// === 約数列挙 ===
function divisors(n) {
    const divs = [];
    for (let i = 1; i * i <= n; i++) {
        if (n % i === 0) {
            divs.push(i);
            if (i !== Math.floor(n / i)) {
                divs.push(Math.floor(n / i));
            }
        }
    }
    return divs.sort((a, b) => a - b);
}
```

### mod演算

#### Python

```python
MOD = 10**9 + 7

# === 繰り返し二乗法 ===
def mod_pow(a, n, mod=MOD):
    result = 1
    while n > 0:
        if n & 1:
            result = result * a % mod
        a = a * a % mod
        n >>= 1
    return result

# === 逆元 ===
def mod_inv(a, mod=MOD):
    return mod_pow(a, mod - 2, mod)

# === 組合せ (前処理) ===
class Combination:
    def __init__(self, n, mod=MOD):
        self.mod = mod
        self.fact = [1] * (n + 1)
        self.inv_fact = [1] * (n + 1)
        for i in range(1, n + 1):
            self.fact[i] = self.fact[i-1] * i % mod
        self.inv_fact[n] = mod_pow(self.fact[n], mod - 2, mod)
        for i in range(n - 1, -1, -1):
            self.inv_fact[i] = self.inv_fact[i+1] * (i+1) % mod

    def C(self, n, r):
        if r < 0 or r > n:
            return 0
        return self.fact[n] * self.inv_fact[r] % self.mod * self.inv_fact[n-r] % self.mod

    def P(self, n, r):
        if r < 0 or r > n:
            return 0
        return self.fact[n] * self.inv_fact[n-r] % self.mod
```

#### JavaScript

```javascript
const MOD = 1000000007n;

// === 繰り返し二乗法 (BigInt版) ===
function modPow(a, n, mod = MOD) {
    let result = 1n;
    a = BigInt(a);
    n = BigInt(n);
    while (n > 0n) {
        if (n & 1n) {
            result = result * a % mod;
        }
        a = a * a % mod;
        n >>= 1n;
    }
    return result;
}

// === 逆元 ===
function modInv(a, mod = MOD) {
    return modPow(a, mod - 2n, mod);
}

// === 組合せ (前処理) ===
class Combination {
    constructor(n, mod = MOD) {
        this.mod = mod;
        this.fact = new Array(n + 1);
        this.invFact = new Array(n + 1);
        this.fact[0] = 1n;
        for (let i = 1; i <= n; i++) {
            this.fact[i] = this.fact[i - 1] * BigInt(i) % mod;
        }
        this.invFact[n] = modPow(this.fact[n], mod - 2n, mod);
        for (let i = n - 1; i >= 0; i--) {
            this.invFact[i] = this.invFact[i + 1] * BigInt(i + 1) % mod;
        }
    }

    C(n, r) {
        if (r < 0 || r > n) return 0n;
        return this.fact[n] * this.invFact[r] % this.mod * this.invFact[n - r] % this.mod;
    }
}
```

---

## エッジケースチェックリスト

```
【数値系】:
□ N = 0, 1 (最小ケース)
□ N = 最大値 (制約上限)
□ 負の数
□ 0 を含む
□ オーバーフロー (JavaScript: BigInt使用)

【配列系】:
□ 空配列
□ 要素1つ
□ 全て同じ値
□ ソート済み（昇順/降順）
□ 重複あり

【文字列系】:
□ 空文字列
□ 1文字
□ 全て同じ文字
□ 特殊文字

【グラフ系】:
□ 頂点1つ
□ 辺なし
□ 完全グラフ
□ 木（連結・辺数 = N-1）
□ 非連結
□ 自己ループ
□ 多重辺
```

## 使用方法

このテンプレートを参照して、`/cp-solve` で問題を解く際に適切なコードを生成します。
