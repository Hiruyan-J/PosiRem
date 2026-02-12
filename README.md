<p align="center">
  <img src="app/assets/images/PosiRem_logo_icon.png" alt="PosiRem! ロゴ" width="120">
</p>

<h1 align="center">PosiRem!</h1>

<p align="center">
  保育者向け AI 言い換えアプリ<br>
  ネガティブ・禁止的な表現を、子どもに伝わるポジティブな表現に変換します
</p>

<p align="center">
  <a href="https://posirem.onrender.com/">https://posirem.onrender.com/</a>
</p>

## サービス概要

保育の現場では「走らないで！」「触っちゃダメ！」など、つい禁止語やネガティブな表現を使ってしまうことがあります。しかし、子どもには**肯定的な言葉**のほうが伝わりやすいと言われています。

**PosiRem!** は、保育者が入力したネガティブ・禁止的な表現を AI（OpenAI GPT-4o-mini）が分析し、子どもに伝わるポジティブな表現に変換するアプリです。

### 主な機能

- **AI によるポジティブ変換** — 1つの入力に対して5つの言い換え候補を生成
- **リアルタイムレスポンス** — Turbo Stream による非同期配信で、待ち時間なくスムーズに結果を表示
- **変換履歴の保存・閲覧** — 過去の変換結果をチャット形式で振り返り、無限スクロールで快適に閲覧

## 画面イメージ

<p align="center">
  <a href="https://gyazo.com/3c60a78d724b96bb4b3d04dea48fe42d">
    <img src="https://i.gyazo.com/3c60a78d724b96bb4b3d04dea48fe42d.png" alt="PosiRem! 画面イメージ" width="300">
  </a>
</p>

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| バックエンド | Ruby 3.3.6 / Rails 7.2.3 |
| フロントエンド | Hotwire（Turbo + Stimulus）/ Tailwind CSS + DaisyUI |
| データベース | PostgreSQL |
| AI | OpenAI API（GPT-4o-mini） |
| 認証 | Devise |
| リアルタイム通信 | Action Cable（Solid Cable） |
| インフラ | Render.com |
| CI/CD | GitHub Actions（Brakeman / RuboCop / Minitest） |

## ER 図

```mermaid
erDiagram
    users ||--o{ conversations : "has many"
    conversations ||--o{ suggestions : "has many"

    users {
        bigint id PK
        string name
        string email
        string encrypted_password
        string reset_password_token
        datetime reset_password_sent_at
        datetime remember_created_at
        datetime created_at
        datetime updated_at
    }

    conversations {
        bigint id PK
        bigint user_id FK
        text original_text
        datetime created_at
        datetime updated_at
    }

    suggestions {
        bigint id PK
        bigint conversation_id FK
        string positive_text
        boolean is_selected
        datetime created_at
        datetime updated_at
    }
```

## 技術的なポイント

### 非同期 AI レスポンス

OpenAI API の呼び出しを Active Job（`AiSuggestionJob`）でバックグラウンド処理し、結果を Turbo Stream でリアルタイム配信しています。ユーザーはリクエスト送信後、ページ遷移なしで AI の回答を受け取れます。

### チャット風 UI

ユーザーの入力（左）と AI の回答（右）を会話形式で表示するチャット風のインターフェースを Turbo Frame / Turbo Stream で実現しています。

### 無限スクロール

Stimulus コントローラー（`InfiniteScrollController`）を使い、変換履歴を遅延読み込みで表示しています。初回表示を高速化しつつ、過去の履歴もスムーズに閲覧できます。

### CI/CD パイプライン

GitHub Actions で以下を自動実行し、コード品質を担保しています。

1. **Brakeman** — セキュリティ脆弱性スキャン
2. **RuboCop** — コードスタイルチェック
3. **Minitest** — ユニットテスト・システムテスト

