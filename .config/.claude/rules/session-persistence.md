# セッション永続化

## 前回セッションの復元

セッション開始時に SessionStart hook が `additionalContext` として前回セッションのサマリーを注入する。
この情報には前回の作業内容・変更ファイル・compact ログが含まれる。

ユーザーが「前回の続き」「前回何をした」「覚えた単語」等と聞いた場合は、**auto memory ではなく、まず additionalContext に注入された Previous Session 情報を参照すること**。
auto memory は長期記憶（ユーザー情報・フィードバック等）用であり、直前セッションの作業状態は session-store が管轄する。

## 参照順序（必須）

前回セッションに関する質問には以下の順序で対応する:

1. **additionalContext の Previous Session セクション**を確認する
2. Previous Session に情報がない場合のみ **auto memory** を検索する
3. 回答時に、どちらの情報源を使ったかを明示する

## 保存先

`~/.claude/session-store/<project-slug>/` にセッションごとの .md ファイルが保存される。
SessionEnd hook がセッション終了時に自動保存し、PreCompact hook が compact 前の状態を追記する。
