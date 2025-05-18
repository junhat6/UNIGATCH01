//
//  FirestoreManager.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/17.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging

class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    func updateDMRoomLastMessage(roomId: String, message: String, senderId: String, messageType: String = "normal", completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let roomRef = db.collection("dm_rooms").document(roomId)
        
        roomRef.updateData([
            "lastMessage": message,
            "lastMessageTimestamp": FieldValue.serverTimestamp(),
            "lastMessageSenderId": senderId,
            "lastMessageType": messageType,
            "unreadCount": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                // メッセージ更新後に通知を送信
                self.sendPushNotification(roomId: roomId, message: message, senderId: senderId, messageType: messageType)
                completion(nil)
            }
        }
    }
    
    func markMessagesAsRead(roomId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let roomRef = db.collection("dm_rooms").document(roomId)
        
        roomRef.updateData([
            "unreadCount": 0,
            "lastReadTimestamp.\(userId)": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error marking messages as read: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Messages marked as read successfully")
                completion(nil)
            }
        }
    }
    
    func sendPushNotification(roomId: String, message: String, senderId: String, messageType: String = "normal") {
        print("Attempting to send push notification for roomId: \(roomId), senderId: \(senderId)")
        let db = Firestore.firestore()
        db.collection("dm_rooms").document(roomId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let hostId = data?["hostId"] as? String ?? ""
                let guestId = data?["guestId"] as? String ?? ""
                
                let recipientId = (senderId == hostId) ? guestId : hostId
                print("Determined recipient ID: \(recipientId)")
                
                self.getFCMToken(for: recipientId) { token in
                    if let token = token {
                        print("Retrieved FCM token for recipient: \(token)")
                        self.sendNotification(to: token, title: "新しいメッセージ", body: message, data: ["roomId": roomId, "messageType": messageType])
                    } else {
                        print("Failed to retrieve FCM token for recipient")
                    }
                }
            } else {
                print("Failed to retrieve DM room document")
            }
        }
    }
    
    private func getFCMToken(for userId: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let fcmToken = document.data()?["fcmToken"] as? String
                completion(fcmToken)
            } else {
                completion(nil)
            }
        }
    }
    
    private func sendNotification(to token: String, title: String, body: String, data: [String: String]) {
        print("Sending notification to FCM token: \(token)")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : data]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=YOUR_SERVER_KEY", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            if let error = error {
                print("Error sending FCM notification: \(error.localizedDescription)")
            } else if let data = data, let jsonDataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("FCM response: \(jsonDataDict)")
            } else {
                print("Unexpected response from FCM")
            }
        }
        task.resume()
    }
    
    func sendMatchingResultNotifications(matchingPostId: String, selectedUserId: String, matchingContent: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let matchingPostRef = db.collection("chats").document("super_nintendo_world").collection("messages").document(matchingPostId)
        
        matchingPostRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let document = document, document.exists,
                  let replies = document.data()?["replies"] as? [[String: Any]] else {
                completion(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid matching post data"]))
                return
            }
            
            for reply in replies {
                guard let replyUserId = reply["senderId"] as? String else { continue }
                
                let isSelected = replyUserId == selectedUserId
                let notificationTitle = isSelected ? "マッチングしました！" : "マッチングの結果"
                let notificationBody = isSelected ?
                    "おめでとうございます！あなたは「\(matchingContent)」にマッチングしました。DMチャットルームが作成されましたので、早速お話しください。" :
                    "残念ながら「\(matchingContent)」のマッチングには至りませんでした。次回の機会にぜひご参加ください！"
                
                self.getFCMToken(for: replyUserId) { token in
                    if let token = token {
                        self.sendNotification(to: token, title: notificationTitle, body: notificationBody, data: ["matchingPostId": matchingPostId])
                    }
                }
            }
            
            completion(nil)
        }
    }
    
    struct UserStatus: Codable {
        let userId: String
        let isOnline: Bool
        let lastActive: Date
    }
    
    func updateUserStatus(userId: String, isOnline: Bool) {
        let db = Firestore.firestore()
        let userStatusRef = db.collection("user_status").document(userId)
        let status = UserStatus(userId: userId, isOnline: isOnline, lastActive: Date())
        
        do {
            try userStatusRef.setData(from: status) { error in
                if let error = error {
                    print("Error updating user status: \(error.localizedDescription)")
                } else {
                    print("User status updated successfully")
                }
            }
        } catch {
            print("Error encoding user status: \(error.localizedDescription)")
        }
    }
}






