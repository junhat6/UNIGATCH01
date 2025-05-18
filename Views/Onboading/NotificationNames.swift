//
//  NotificationNames.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/17.
//

import Foundation

extension Notification.Name {
    // MARK: - アプリ全体で使用される通知名

    /// スーパーニンテンドーワールドチャットを閉じる
    static let dismissSuperNintendoWorldChat = Notification.Name("dismissSuperNintendoWorldChat")

    /// DMルームが作成された
    static let dmRoomCreated = Notification.Name("dmRoomCreated")

    /// メッセージタブに切り替える
    static let switchToMessagesTab = Notification.Name("switchToMessagesTab")

    /// DMルームを開く
    static let openDMRoom = Notification.Name("openDMRoom")

    // MARK: - その他のカスタム通知名をここに追加

    /// マッチング結果を受信
    static let matchingResultReceived = Notification.Name("matchingResultReceived")

    // 例：
    // static let userProfileUpdated = Notification.Name("userProfileUpdated")
    // static let newMessageReceived = Notification.Name("newMessageReceived")
}


