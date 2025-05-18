//
//  DMCreationViewModel.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/19.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class DMCreationViewModel: ObservableObject {
    @Published var replies: [Reply]
    @Published var originalPostContent: String
    private let db = Firestore.firestore()
    private let matchingPostId: String
    
    init(matchingPostId: String, preloadedContent: String, preloadedReplies: [Reply]) {
        print("DMCreationViewModel init - matchingPostId: \(matchingPostId)")
        self.matchingPostId = matchingPostId
        self.originalPostContent = preloadedContent
        self.replies = preloadedReplies
        print("Initialized with \(preloadedReplies.count) replies")
    }
    
    func createDMRoom(hostId: String, guestId: String, matchingPostContent: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Creating DM room - hostId: \(hostId), guestId: \(guestId)")
        let dmRoomRef = db.collection("dm_rooms").document()
        let dmRoomData: [String: Any] = [
            "hostId": hostId,
            "guestId": guestId,
            "createdAt": FieldValue.serverTimestamp(),
            "lastMessage": matchingPostContent,
            "lastMessageTimestamp": FieldValue.serverTimestamp(),
            "unreadCount": 1
        ]
        
        dmRoomRef.setData(dmRoomData) { [weak self] error in
            guard let self = self else {
                completion(.failure(NSError(domain: "DMCreationViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            if let error = error {
                print("Error creating DM room: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("DM room created successfully")
                let messageData: [String: Any] = [
                    "content": matchingPostContent,
                    "senderId": hostId,
                    "senderName": "System",
                    "timestamp": FieldValue.serverTimestamp(),
                    "type": "matchingPost"
                ]
                dmRoomRef.collection("messages").addDocument(data: messageData) { error in
                    if let error = error {
                        print("Error adding initial message: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("Initial message added successfully")
                        // Close the matching post
                        let chatViewModel = ChatViewModel(chatRoomId: "super_nintendo_world")
                        chatViewModel.closeMatchingPost(messageId: self.matchingPostId)
                        
                        self.sendMatchingNotifications(
                            matchingPostCreatorId: hostId,
                            selectedUserId: guestId,
                            matchingContent: matchingPostContent,
                            dmRoomId: dmRoomRef.documentID
                        )
                        completion(.success(dmRoomRef.documentID))
                    }
                }
            }
        }
    }

    private func sendMatchingNotifications(matchingPostCreatorId: String, selectedUserId: String, matchingContent: String, dmRoomId: String) {
        db.collection("chats")
            .document("super_nintendo_world")
            .collection("messages")
            .document(matchingPostId)
            .getDocument { [weak self] (document, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Failed to fetch matching post data: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document,
                      let data = document.data(),
                      let replies = data["replies"] as? [[String: Any]] else {
                    print("❌ Invalid matching post data")
                    return
                }
                
                // 1. マッチング投稿作成者への通知
                self.sendNotificationToUser(
                    userId: matchingPostCreatorId,
                    message: "DMルームを作成しました。",
                    dmRoomId: dmRoomId
                )
                
                // 2. リプライしたユーザーへの通知
                for reply in replies {
                    guard let replyUserId = reply["senderId"] as? String else { continue }
                    
                    if replyUserId == selectedUserId {
                        // 選択されたユーザーへの通知
                        self.sendNotificationToUser(
                            userId: replyUserId,
                            message: "マッチングが成立しました！DMルームが作成されました。",
                            dmRoomId: dmRoomId
                        )
                    } else if replyUserId != matchingPostCreatorId {
                        // 選択されなかったユーザーへの通知
                        self.sendNotificationToUser(
                            userId: replyUserId,
                            message: "マッチングは成立しませんでした。",
                            dmRoomId: ""
                        )
                    }
                }
            }
    }
    
    private func sendNotificationToUser(userId: String, message: String, dmRoomId: String) {
        let notificationRef = db.collection("matching_notifications").document()
        let notificationData: [String: Any] = [
            "userId": userId,
            "message": message,
            "timestamp": FieldValue.serverTimestamp(),
            "dmRoomId": dmRoomId,
            "isRead": false
        ]
        
        notificationRef.setData(notificationData) { error in
            if let error = error {
                print("❌ Failed to save notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification saved successfully for user: \(userId)")
            }
        }
    }
}









