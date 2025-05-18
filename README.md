# UNIGATCH02

USJで出会いを探すためのマッチングアプリ「UNIGATCH」のiOSアプリケーションです。
神戸電子専門学校でのDigitalWorksでの作品です。「プレゼン賞」を頂きました。

## 概要

UNIGATCHは、ユニバーサル・スタジオ・ジャパン（USJ）のエリアをベースにしたマッチングアプリです。同じエリアや同じ趣味を持つユーザー同士で交流することができます。
https://youtu.be/e1OFTqIwheQ?si=Y2MLaqhXb3vuDj2K

## 機能

- ユーザー認証（メール/パスワードのみ実装）
- プロフィール作成・編集
- エリアごとのオープンチャット
  - スーパーニンテンドーワールドのみ実装
- ダイレクトメッセージ
- 通知（iphoneのプッシュ通知は未実装）

## 技術スタック

- SwiftUI
- Firebase Authentication
- Cloud Firestore
- SwiftData

## 必要条件

- iOS 17.0以上
- Xcode 15.0以上

## アプリ構成

- `App/` - アプリケーションのエントリーポイント
- `Views/` - UIコンポーネント
  - `Authentication/` - 認証関連のビュー
  - `Chat/` - チャット機能のコンポーネント
  - `DM/` - ダイレクトメッセージ関連
  - `Main/` - メインのナビゲーション
  - `Profile/` - プロフィール管理
- `Services/` - Firebaseやデータ操作のサービス
- `UserProfile/` - ユーザープロフィールのモデル
- `Utils/` - ユーティリティクラス

## 開発者

- 服部潤一
