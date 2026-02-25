# Theme Guidelines

## 概要

AIが選びがちな汎用カラー（紫グラデ、青ボタン）を避け、
ブランドに沿った独自性のあるカラースキームを実現する。

---

## 禁止カラーパターン

### 絶対に避けるべき

```css
/* これらは使わない */
background: linear-gradient(to right, #667eea, #764ba2);
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
background: linear-gradient(to bottom right, #4f46e5, #7c3aed);

/* 汎用青ボタン */
background-color: #007bff;  /* Bootstrap blue */
background-color: #3b82f6;  /* Tailwind blue-500 をそのまま */
```

### 避けるべき傾向

- 紫色全般（`#7c3aed`, `#8b5cf6` など）をグラデーションで使用
- 青→紫のグラデーション
- 白背景に薄い紫アクセント
- Bootstrap/Tailwindのデフォルトカラーをそのまま使用

---

## 推奨カラーパレット

### メインパレット（クール系 - ティール/エメラルド）

```css
:root {
    /* プライマリ */
    --primary-50: #F0FDFA;
    --primary-100: #CCFBF1;
    --primary-200: #99F6E4;
    --primary-300: #5EEAD4;
    --primary-400: #2DD4BF;
    --primary-500: #14B8A6;
    --primary-600: #0D9488;  /* メイン */
    --primary-700: #0F766E;
    --primary-800: #115E59;
    --primary-900: #134E4A;

    /* アクセント（エメラルド） */
    --accent-500: #10B981;
    --accent-600: #059669;

    /* ニュートラル（スレート） */
    --neutral-50: #F8FAFC;
    --neutral-100: #F1F5F9;
    --neutral-200: #E2E8F0;
    --neutral-300: #CBD5E1;
    --neutral-400: #94A3B8;
    --neutral-500: #64748B;
    --neutral-600: #475569;
    --neutral-700: #334155;
    --neutral-800: #1E293B;
    --neutral-900: #0F172A;
}
```

### Tailwind設定

```js
// tailwind.config.js
module.exports = {
    theme: {
        extend: {
            colors: {
                primary: {
                    50: '#F0FDFA',
                    100: '#CCFBF1',
                    200: '#99F6E4',
                    300: '#5EEAD4',
                    400: '#2DD4BF',
                    500: '#14B8A6',
                    600: '#0D9488',
                    700: '#0F766E',
                    800: '#115E59',
                    900: '#134E4A',
                },
                accent: {
                    500: '#10B981',
                    600: '#059669',
                },
            },
        },
    },
}
```

---

## 代替パレット

### ウォーム系（アンバー/オレンジ）

```css
:root {
    --primary: #D97706;      /* アンバー */
    --secondary: #92400E;    /* ダークブラウン */
    --accent: #F59E0B;       /* ゴールド */
    --background: #FFFBEB;   /* クリーム */
    --foreground: #1F2937;   /* ダークグレー */
}
```

### ニュートラル系（グレー + アクセント）

```css
:root {
    --primary: #4B5563;      /* グレー */
    --secondary: #1F2937;    /* ダークグレー */
    --accent: #10B981;       /* エメラルド（アクセントのみ彩度高） */
    --background: #F9FAFB;   /* ライトグレー */
    --foreground: #111827;   /* ほぼ黒 */
}
```

---

## コンポーネント例

### ボタン

```tsx
{/* プライマリボタン */}
<button className="bg-teal-600 hover:bg-teal-500 text-white px-6 py-3 font-medium transition-colors">
    Primary Action
</button>

{/* セカンダリボタン */}
<button className="bg-transparent border border-teal-600 text-teal-600 hover:bg-teal-50 px-6 py-3 font-medium transition-colors">
    Secondary Action
</button>

{/* ゴーストボタン */}
<button className="text-slate-600 hover:text-slate-900 hover:bg-slate-100 px-4 py-2 transition-colors">
    Ghost Action
</button>
```

### カード

```tsx
<div className="bg-white border border-slate-200 p-6 shadow-sm hover:shadow-md transition-shadow">
    <h3 className="text-lg font-semibold text-slate-900">Card Title</h3>
    <p className="mt-2 text-slate-600">Card description text.</p>
</div>
```

### バッジ/タグ

```tsx
{/* ステータスバッジ */}
<span className="inline-flex items-center px-2.5 py-0.5 text-xs font-medium bg-teal-100 text-teal-800">
    Active
</span>

<span className="inline-flex items-center px-2.5 py-0.5 text-xs font-medium bg-amber-100 text-amber-800">
    Pending
</span>
```

---

## ビジュアルスタイルガイド

### スタイル1: ミニマリスト

- 高コントラスト
- 余白を大きく取る
- 色数を絞る（3-4色）
- シャドウは控えめまたはなし

```tsx
<div className="bg-white p-8">
    <h2 className="text-2xl font-bold text-slate-900">Clean Design</h2>
    <p className="mt-4 text-slate-600 leading-relaxed">
        Minimal colors, generous whitespace.
    </p>
</div>
```

### スタイル2: グラスモーフィズム

```tsx
<div className="bg-white/70 backdrop-blur-lg border border-white/20 rounded-2xl p-6 shadow-xl">
    <h3 className="text-lg font-semibold">Glass Card</h3>
    <p className="text-slate-600">Frosted glass effect.</p>
</div>
```

### スタイル3: ニューモーフィズム

```tsx
<div className="bg-slate-100 rounded-2xl p-6 shadow-[20px_20px_60px_#bebebe,-20px_-20px_60px_#ffffff]">
    <h3 className="text-lg font-semibold text-slate-800">Soft UI</h3>
    <p className="text-slate-600">Subtle depth with shadows.</p>
</div>
```

---

## ダークモード対応

```tsx
{/* ライト/ダーク両対応 */}
<div className="bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100">
    <h1 className="text-2xl font-bold">Adaptive Title</h1>
    <p className="text-slate-600 dark:text-slate-400">
        Adapts to user preference.
    </p>
</div>
```

```css
/* ダークモード時も真っ黒を避ける */
[data-theme="dark"] {
    --background: #0F172A;  /* slate-900（黒ではない） */
    --foreground: #F1F5F9;  /* slate-100 */
    --muted: #94A3B8;       /* slate-400 */
}
```

---

## チェックリスト

- [ ] 紫グラデーションを使っていない
- [ ] デフォルトの青ボタン（#007bff）をカスタマイズした
- [ ] 配色に意図と統一感がある
- [ ] コントラスト比がWCAG基準を満たす（4.5:1以上）
- [ ] ダークモード時も視認性が確保されている
- [ ] ホバー/フォーカス状態の色が定義されている
