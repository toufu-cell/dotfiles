# Anti-Patterns Guide

## 概要

AI生成UIで頻出する「AIっぽさ」を認識し、それを意識的に避けるためのガイド。

## 「AI slop」の典型的特徴

### 1. 配色

**避けるべきパターン:**
- 黒背景 + 紫/青のグラデーション
- `#667eea`, `#764ba2` 周辺の紫
- 汎用的な青ボタン (`#007bff`, `#3b82f6`)
- 白背景に薄い紫アクセント

```css
/* これらは使わない */
background: linear-gradient(to right, #667eea, #764ba2);
background: linear-gradient(135deg, #4f46e5, #7c3aed);
```

### 2. タイポグラフィ

**避けるべきパターン:**
- Interフォント（圧倒的に多い）
- Roboto、Open Sans
- 単調なフォントウェイト（全体的に400）
- システムフォントスタックのみ

### 3. レイアウト

**避けるべきパターン:**
- 予測可能なカードグリッド（3列）
- センター寄せヒーローセクション
- 3カラムの特徴セクション（アイコン + 見出し + 説明）
- 「お客様の声」カルーセル

### 4. コンポーネント

**避けるべきパターン:**
- 角丸のカード（border-radius: 8px-16px をそのまま）
- 青い「Get Started」ボタン
- アイコン + テキストの繰り返しリスト
- 薄いボーダーのインプットフィールド

### 5. コピー

**避けるべきフレーズ:**
- 「Revolutionize your workflow」
- 「Powered by AI」
- 「Join thousands of satisfied customers」
- 「Get started for free」

---

## 自己診断チェックリスト

### カラー
- [ ] 紫グラデーションを使っていない
- [ ] `#667eea`, `#764ba2` 周辺の色を避けている
- [ ] プライマリカラーがBootstrap/Tailwindデフォルトではない
- [ ] アクセントカラーに意図がある

### タイポグラフィ
- [ ] Inter, Roboto, Open Sans 以外のフォントを使っている
- [ ] フォントペアリングに意図がある
- [ ] フォントウェイトに変化がある

### レイアウト
- [ ] 3カラム特徴セクション以外のレイアウトを検討した
- [ ] 予測可能すぎないグリッド構成にした
- [ ] 余白の取り方に独自性がある

### コンポーネント
- [ ] ボタンのスタイルをカスタマイズした
- [ ] カードに独自のスタイルを適用した
- [ ] フォーム要素をデフォルトから変更した

### モーション
- [ ] 必要以上のアニメーションを追加していない
- [ ] アニメーションに目的がある
- [ ] 過度なバウンスエフェクトを避けている

---

## Before / After 例

### Before（AIっぽい）

```tsx
// 避けるべき典型例
<section className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white py-20">
    <div className="container mx-auto text-center">
        <h1 className="text-5xl font-bold mb-4">
            Revolutionize Your Workflow
        </h1>
        <p className="text-xl mb-8 text-gray-200">
            Join thousands of satisfied customers
        </p>
        <button className="bg-blue-500 hover:bg-blue-600 text-white rounded-lg px-8 py-4 text-lg">
            Get Started Free
        </button>
    </div>
</section>
```

**問題点:**
- 紫グラデーション背景
- 汎用的なコピー
- 青い丸ボタン
- センター寄せの定型レイアウト

### After（改善後）

```tsx
// 改善例
<section className="relative bg-slate-50 py-24">
    {/* 背景パターン */}
    <div className="absolute inset-0 bg-grid-slate-100 [mask-image:linear-gradient(0deg,white,rgba(255,255,255,0.5))]" />

    <div className="relative container mx-auto px-6">
        <div className="max-w-2xl">
            <span className="inline-block px-3 py-1 text-sm font-medium text-teal-700 bg-teal-50 rounded-full mb-4">
                New Release
            </span>
            <h1 className="text-4xl font-display font-bold tracking-tight text-slate-900 sm:text-5xl">
                Ship features faster
            </h1>
            <p className="mt-6 text-lg text-slate-600 leading-relaxed">
                Stop wrestling with deployment pipelines.
                Focus on what matters: building great products.
            </p>
            <div className="mt-10 flex gap-4">
                <button className="bg-teal-600 hover:bg-teal-500 text-white px-6 py-3 text-sm font-medium transition-all hover:-translate-y-0.5 hover:shadow-lg">
                    Start building
                </button>
                <button className="text-slate-700 hover:text-slate-900 px-6 py-3 text-sm font-medium border border-slate-200 hover:border-slate-300 transition-colors">
                    View docs
                </button>
            </div>
        </div>
    </div>
</section>
```

**改善点:**
- 紫グラデ → グリッドパターン付きライト背景
- 汎用コピー → 具体的で短いコピー
- 青ボタン → ティール + ホバーエフェクト
- センター寄せ → 左寄せ、非対称レイアウト
- 角丸なし（シャープ）でモダンな印象

---

## 良質なデザインの特徴

### 識別性
- 一目でブランドがわかる
- 他のサイトと差別化されている
- 意図を持ったデザイン決定がある

### 一貫性
- カラー、タイポグラフィ、スペーシングに統一感
- コンポーネント間でスタイルが揃っている
- トーン&マナーが一貫している

### 目的性
- 各要素に理由がある
- 装飾のためだけの要素がない
- ユーザー体験を向上させている
