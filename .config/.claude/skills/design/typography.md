# Typography Guidelines

## 概要

AIが統計的に選びがちな汎用フォントを避け、
個性的で意図のあるタイポグラフィを実現する。

---

## 禁止フォント

以下のフォントは **絶対に使用しない**:

| フォント | 理由 |
|---------|------|
| Inter | 最も頻繁にAIが選ぶフォント |
| Roboto | Androidデフォルト、汎用的すぎる |
| Open Sans | 汎用的すぎる |
| Arial | システムフォント、個性がない |
| Helvetica | 汎用的すぎる |

```css
/* これは使わない */
font-family: 'Inter', sans-serif;
font-family: 'Roboto', sans-serif;
font-family: -apple-system, BlinkMacSystemFont, sans-serif;
```

---

## 推奨フォント

### 見出し用（Display）

| フォント名 | 特徴 | 用途 |
|-----------|------|------|
| **Playfair Display** | エレガントなセリフ | 高級感、エディトリアル |
| **Merriweather** | 読みやすいセリフ | 信頼感、プロフェッショナル |
| **Poppins** | 幾何学的サンセリフ | モダン、フレンドリー |
| **Space Grotesk** | 特徴的なサンセリフ | テック、スタートアップ |
| **Outfit** | 可変フォント | 柔軟性、モダン |
| **Sora** | 幾何学+人間味 | SaaS、プロダクト |

### 本文用（Body）

| フォント名 | 特徴 | 用途 |
|-----------|------|------|
| **DM Sans** | 低コントラストサンセリフ | UI、アプリ |
| **Manrope** | モダンサンセリフ | SaaS、ダッシュボード |
| **Source Serif Pro** | 高品質セリフ | 長文読解 |
| **Lora** | 優美なセリフ | ブログ、記事 |
| **Noto Sans JP** | 日本語対応 | 日本語コンテンツ |
| **IBM Plex Sans** | 中立的で読みやすい | 技術文書、UI |

### コード/等幅

| フォント名 | 特徴 |
|-----------|------|
| **JetBrains Mono** | リガチャ対応、開発者向け |
| **Fira Code** | プログラミング最適化 |
| **Source Code Pro** | Adobe製、高品質 |

---

## フォントペアリング例

### パターン1: エレガント（高級感）

```css
:root {
    --font-heading: 'Playfair Display', serif;
    --font-body: 'Source Serif Pro', serif;
}
```

```tsx
<h1 className="font-serif text-4xl font-bold">
    Crafted with precision
</h1>
<p className="font-body text-lg leading-relaxed">
    Every detail matters in creating exceptional experiences.
</p>
```

### パターン2: モダンテック（スタートアップ向け）

```css
:root {
    --font-heading: 'Space Grotesk', sans-serif;
    --font-body: 'DM Sans', sans-serif;
}
```

```tsx
<h1 className="font-display text-4xl font-bold tracking-tight">
    Build faster, ship smarter
</h1>
<p className="font-sans text-lg text-slate-600">
    The developer platform for modern teams.
</p>
```

### パターン3: フレンドリー（B2C向け）

```css
:root {
    --font-heading: 'Poppins', sans-serif;
    --font-body: 'Manrope', sans-serif;
}
```

```tsx
<h1 className="font-display text-4xl font-semibold">
    Welcome back!
</h1>
<p className="font-sans text-lg">
    Let's pick up where you left off.
</p>
```

---

## Tailwind設定例

```js
// tailwind.config.js
module.exports = {
    theme: {
        extend: {
            fontFamily: {
                display: ['Space Grotesk', 'sans-serif'],
                body: ['DM Sans', 'sans-serif'],
                mono: ['JetBrains Mono', 'monospace'],
            },
        },
    },
}
```

```html
<!-- Google Fonts 読み込み -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
```

---

## タイポグラフィ原則

### 1. コントラストを持たせる

```tsx
{/* 見出しと本文で明確に異なるスタイル */}
<h1 className="font-display text-4xl font-bold tracking-tight">
    Heading
</h1>
<p className="font-body text-base font-normal leading-relaxed">
    Body text with different weight and tracking.
</p>
```

### 2. 階層を明確に

```tsx
<h1 className="text-4xl font-bold">h1 - 36-48px</h1>
<h2 className="text-3xl font-semibold">h2 - 30px</h2>
<h3 className="text-2xl font-semibold">h3 - 24px</h3>
<h4 className="text-xl font-medium">h4 - 20px</h4>
<p className="text-base">Body - 16px</p>
<small className="text-sm">Small - 14px</small>
```

### 3. 読みやすさを確保

```tsx
{/* 本文は16px以上、行長は45-75文字 */}
<p className="text-base leading-relaxed max-w-prose">
    Long form content should have comfortable line height
    and constrained width for optimal readability.
</p>
```

---

## 日本語フォント対応

```css
:root {
    --font-heading: 'Noto Sans JP', 'Hiragino Sans', sans-serif;
    --font-body: 'Noto Sans JP', 'Hiragino Sans', sans-serif;
}
```

```tsx
<h1 className="font-sans text-3xl font-bold tracking-tight">
    日本語見出し
</h1>
<p className="font-sans text-base leading-loose">
    本文テキストは適切な行間を確保して読みやすくします。
</p>
```

---

## チェックリスト

- [ ] Inter, Roboto, Open Sans を使っていない
- [ ] 見出しと本文で異なるフォント/ウェイトを使用
- [ ] フォントサイズの階層が明確
- [ ] 本文は16px以上
- [ ] line-height が適切（1.5-1.8）
- [ ] 日本語コンテンツがある場合は日本語フォントを指定
