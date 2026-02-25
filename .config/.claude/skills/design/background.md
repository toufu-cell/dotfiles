# Background Guidelines

## 概要

AIが生成しがちな紫グラデーション背景を避け、
テクスチャやパターンで深みのある背景を実現する。

---

## 禁止パターン

### 絶対に避けるべき

```css
/* これらは使わない */
background: linear-gradient(to right, #667eea, #764ba2);
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
background: linear-gradient(to bottom right, #4f46e5, #7c3aed);
background: linear-gradient(135deg, #6366f1, #8b5cf6);
```

### 避けるべき傾向

- 紫色全般（`#7c3aed`, `#8b5cf6`, `#6366f1` など）をグラデーションで使用
- 青→紫のグラデーション
- 汎用的な線形グラデーションの多用
- 白背景に薄い紫アクセント
- 単調な単色背景（白、黒のみ）

---

## 推奨パターン

### 1. ドットパターン

```tsx
{/* Tailwind + カスタムCSS */}
<div className="relative min-h-screen bg-slate-50">
    <div
        className="absolute inset-0"
        style={{
            backgroundImage: 'radial-gradient(#cbd5e1 1px, transparent 1px)',
            backgroundSize: '20px 20px',
        }}
    />
    <div className="relative z-10">
        {/* コンテンツ */}
    </div>
</div>
```

### 2. グリッドパターン

```tsx
<div className="relative min-h-screen bg-white">
    <div
        className="absolute inset-0"
        style={{
            backgroundImage: `
                linear-gradient(to right, #f1f5f9 1px, transparent 1px),
                linear-gradient(to bottom, #f1f5f9 1px, transparent 1px)
            `,
            backgroundSize: '24px 24px',
        }}
    />
    <div className="relative z-10">
        {/* コンテンツ */}
    </div>
</div>
```

### 3. ノイズテクスチャ

```tsx
{/* SVGノイズを使った深み */}
<div className="relative min-h-screen bg-slate-100">
    <div
        className="absolute inset-0 opacity-50"
        style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 400 400' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E")`,
        }}
    />
    <div className="relative z-10">
        {/* コンテンツ */}
    </div>
</div>
```

### 4. 控えめなグラデーション（紫以外）

```tsx
{/* ティール系 - 推奨 */}
<div className="bg-gradient-to-br from-teal-50 to-emerald-50 min-h-screen">
    {/* コンテンツ */}
</div>

{/* ニュートラル系 */}
<div className="bg-gradient-to-b from-slate-50 to-slate-100 min-h-screen">
    {/* コンテンツ */}
</div>

{/* ウォーム系 */}
<div className="bg-gradient-to-br from-amber-50 to-orange-50 min-h-screen">
    {/* コンテンツ */}
</div>
```

### 5. 放射状グラデーション（アクセント用）

```tsx
{/* ヒーローセクションのアクセント */}
<div className="relative overflow-hidden bg-slate-900">
    {/* 背景のグロー効果 */}
    <div
        className="absolute top-0 right-0 w-96 h-96 opacity-30"
        style={{
            background: 'radial-gradient(circle, #14b8a6 0%, transparent 70%)',
        }}
    />
    <div
        className="absolute bottom-0 left-0 w-96 h-96 opacity-20"
        style={{
            background: 'radial-gradient(circle, #10b981 0%, transparent 70%)',
        }}
    />
    <div className="relative z-10">
        {/* コンテンツ */}
    </div>
</div>
```

---

## Tailwindカスタムクラス設定

```js
// tailwind.config.js
module.exports = {
    theme: {
        extend: {
            backgroundImage: {
                'grid-slate': `
                    linear-gradient(to right, #f1f5f9 1px, transparent 1px),
                    linear-gradient(to bottom, #f1f5f9 1px, transparent 1px)
                `,
                'dots-slate': 'radial-gradient(#cbd5e1 1px, transparent 1px)',
            },
            backgroundSize: {
                'grid': '24px 24px',
                'dots': '20px 20px',
            },
        },
    },
}
```

```tsx
{/* 使用例 */}
<div className="bg-grid-slate bg-grid">
    {/* コンテンツ */}
</div>
```

---

## セクション別の背景例

### ヒーローセクション

```tsx
<section className="relative bg-slate-900 text-white py-24">
    {/* グリッドパターン */}
    <div
        className="absolute inset-0 opacity-10"
        style={{
            backgroundImage: `
                linear-gradient(to right, #334155 1px, transparent 1px),
                linear-gradient(to bottom, #334155 1px, transparent 1px)
            `,
            backgroundSize: '32px 32px',
        }}
    />
    {/* グロー効果 */}
    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-teal-500/20 rounded-full blur-3xl" />

    <div className="relative container mx-auto px-6">
        <h1 className="text-5xl font-bold">Hero Title</h1>
    </div>
</section>
```

### フィーチャーセクション

```tsx
<section className="bg-gradient-to-b from-white to-slate-50 py-20">
    <div className="container mx-auto px-6">
        <h2 className="text-3xl font-bold text-slate-900">Features</h2>
        {/* フィーチャーグリッド */}
    </div>
</section>
```

### CTAセクション

```tsx
<section className="relative bg-teal-600 text-white py-16 overflow-hidden">
    {/* 装飾的な円 */}
    <div className="absolute -top-20 -right-20 w-64 h-64 bg-teal-500 rounded-full opacity-50" />
    <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-teal-700 rounded-full opacity-50" />

    <div className="relative container mx-auto px-6 text-center">
        <h2 className="text-3xl font-bold">Ready to get started?</h2>
    </div>
</section>
```

---

## ダークモードでの背景

```tsx
{/* ダークモード対応 - 真っ黒を避ける */}
<div className="bg-white dark:bg-slate-900 min-h-screen">
    {/* slate-900 (#0F172A) は純黒より柔らかい */}
</div>

{/* ダークモード用グリッド */}
<div
    className="absolute inset-0 dark:opacity-5"
    style={{
        backgroundImage: `
            linear-gradient(to right, #475569 1px, transparent 1px),
            linear-gradient(to bottom, #475569 1px, transparent 1px)
        `,
        backgroundSize: '24px 24px',
    }}
/>
```

---

## チェックリスト

- [ ] 紫グラデーションを使っていない
- [ ] 青→紫のグラデーションを使っていない
- [ ] 背景が単調すぎない（テクスチャやパターンで深みを追加）
- [ ] コンテンツの可読性を妨げていない
- [ ] ダークモード時も視覚的な深みがある
- [ ] 複雑すぎるパターンでパフォーマンスに影響していない
