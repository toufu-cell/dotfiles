# Motion Guidelines

## 概要

静的で無機質なUIに生命感を与え、
ユーザー体験を向上させるアニメーションを実装する。

---

## 基本原則

### 1. 意味のあるモーション

- すべてのアニメーションには目的があるべき
- 装飾のためだけのアニメーションは避ける
- ユーザーの注意を誘導するために使う

### 2. 適切なタイミング

| 用途 | 推奨時間 |
|------|----------|
| マイクロインタラクション | 100-200ms |
| 状態変化 | 200-300ms |
| ページ遷移 | 300-500ms |

**500msを超えるアニメーションは避ける**

### 3. イージング関数

```css
/* 推奨 */
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);
--ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);

/* 避ける */
ease-in   /* 終わりが唐突 */
linear    /* 機械的すぎる */
```

---

## Tailwindでの実装

### 基本トランジション

```tsx
{/* ホバー時の変化 */}
<button className="transition-all duration-200 ease-out hover:scale-105 hover:shadow-lg">
    Button
</button>

{/* 色の変化 */}
<a className="text-slate-600 hover:text-teal-600 transition-colors duration-200">
    Link
</a>

{/* 複数プロパティ */}
<div className="transition-all duration-300 hover:-translate-y-1 hover:shadow-xl">
    Card
</div>
```

### ホバーエフェクト

```tsx
{/* カードのホバー */}
<div className="group bg-white border border-slate-200 p-6 transition-all duration-300 hover:border-teal-200 hover:shadow-lg">
    <h3 className="text-lg font-semibold group-hover:text-teal-600 transition-colors">
        Title
    </h3>
</div>

{/* ボタンのホバー */}
<button className="bg-teal-600 text-white px-6 py-3 transition-all duration-200 hover:bg-teal-500 hover:-translate-y-0.5 hover:shadow-md active:translate-y-0">
    Click me
</button>
```

---

## Framer Motion での実装

### フェードイン + スライドアップ

```tsx
import { motion } from 'framer-motion';

function FadeInUp({ children }) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        >
            {children}
        </motion.div>
    );
}
```

### スタガーアニメーション（段階的表示）

```tsx
import { motion } from 'framer-motion';

const container = {
    hidden: { opacity: 0 },
    show: {
        opacity: 1,
        transition: {
            staggerChildren: 0.1,
        },
    },
};

const item = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.4 } },
};

function StaggerList({ items }) {
    return (
        <motion.ul
            variants={container}
            initial="hidden"
            animate="show"
        >
            {items.map((i, index) => (
                <motion.li key={index} variants={item}>
                    {i}
                </motion.li>
            ))}
        </motion.ul>
    );
}
```

### スクロールトリガー

```tsx
import { motion } from 'framer-motion';

function ScrollReveal({ children }) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-100px' }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        >
            {children}
        </motion.div>
    );
}
```

### ホバーアニメーション

```tsx
<motion.div
    whileHover={{ scale: 1.02, y: -4 }}
    whileTap={{ scale: 0.98 }}
    transition={{ type: 'spring', stiffness: 400, damping: 25 }}
    className="bg-white p-6 rounded-lg shadow-sm"
>
    Interactive Card
</motion.div>
```

---

## 具体的なパターン

### 1. ページロード時のアニメーション

```tsx
function HeroSection() {
    return (
        <section className="py-24">
            <motion.span
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-teal-600 text-sm font-medium"
            >
                Introducing
            </motion.span>

            <motion.h1
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="text-5xl font-bold mt-2"
            >
                Product Name
            </motion.h1>

            <motion.p
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="text-slate-600 mt-4"
            >
                Description text
            </motion.p>

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="mt-8"
            >
                <button className="bg-teal-600 text-white px-6 py-3">
                    Get Started
                </button>
            </motion.div>
        </section>
    );
}
```

### 2. カードグリッドのアニメーション

```tsx
function FeatureGrid({ features }) {
    return (
        <motion.div
            initial="hidden"
            whileInView="show"
            viewport={{ once: true }}
            variants={{
                hidden: {},
                show: { transition: { staggerChildren: 0.1 } },
            }}
            className="grid grid-cols-3 gap-6"
        >
            {features.map((feature, i) => (
                <motion.div
                    key={i}
                    variants={{
                        hidden: { opacity: 0, y: 20 },
                        show: { opacity: 1, y: 0 },
                    }}
                    className="bg-white p-6 border border-slate-200"
                >
                    {feature.title}
                </motion.div>
            ))}
        </motion.div>
    );
}
```

### 3. モーダル/ダイアログ

```tsx
function Modal({ isOpen, onClose, children }) {
    return (
        <AnimatePresence>
            {isOpen && (
                <>
                    {/* オーバーレイ */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 bg-black/50 z-40"
                    />
                    {/* モーダル本体 */}
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.95, y: 20 }}
                        transition={{ type: 'spring', damping: 25 }}
                        className="fixed inset-0 flex items-center justify-center z-50"
                    >
                        <div className="bg-white p-8 rounded-lg max-w-md w-full">
                            {children}
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}
```

---

## 禁止パターン

### 避けるべきアニメーション

- **過度なバウンス**: `ease-in-out-back` の多用
- **長すぎるアニメーション**: 1秒以上
- **唐突な変化**: イージングなしの状態変化
- **過剰な回転/スピン**: ローディング以外での使用
- **点滅**: アクセシビリティの問題

```tsx
{/* 避ける */}
<motion.div
    animate={{ rotate: 360 }}
    transition={{ duration: 2, repeat: Infinity }}
>
    過剰な回転
</motion.div>

<div className="animate-bounce">
    過度なバウンス
</div>
```

---

## アクセシビリティ考慮

```css
/* モーション軽減設定を尊重 */
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

```tsx
// Framer Motion でのモーション軽減対応
import { useReducedMotion } from 'framer-motion';

function AnimatedComponent() {
    const prefersReducedMotion = useReducedMotion();

    return (
        <motion.div
            initial={prefersReducedMotion ? false : { opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
        >
            Content
        </motion.div>
    );
}
```

---

## チェックリスト

- [ ] すべてのアニメーションに目的がある
- [ ] アニメーション時間が500ms以下
- [ ] ease-out または適切なイージングを使用
- [ ] 過度なバウンスエフェクトを避けている
- [ ] prefers-reduced-motion を尊重している
- [ ] ホバー/フォーカス状態が適切にアニメーション
