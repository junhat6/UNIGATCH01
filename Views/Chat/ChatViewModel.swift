//
//  ChatViewModel.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import Foundation
import Firebase
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var latestMessageId: String?
    @Published var error: Error?
    private var db = Firestore.firestore()
    var chatRoomId: String
    
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
    }
    
    func sendMessage(_ message: String, sender: UserProfile) {
        guard !sender.nickname.isEmpty else {
            setError(NSError(domain: "ChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nickname is empty"]))
            return
        }
        guard let senderId = sender.id else {
            setError(NSError(domain: "ChatViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"]))
            return
        }
        
        let newMessage = ChatMessage(senderId: senderId,
                                     senderName: sender.nickname,
                                     senderIconUrl: sender.iconImageUrl,
                                     message: message,
                                     timestamp: Date(),
                                     type: .normal)
        
        do {
            try db.collection("chats").document(chatRoomId).collection("messages").addDocument(from: newMessage)
            print("Message sent successfully")
            self.latestMessageId = newMessage.id
        } catch {
            setError(error)
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func sendMatchingPost(_ post: MatchingPost, sender: UserProfile) {
        guard !sender.nickname.isEmpty else {
            setError(NSError(domain: "ChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nickname is empty"]))
            return
        }
        guard let senderId = sender.id else {
            setError(NSError(domain: "ChatViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"]))
            return
        }
        
        let messageContent = """
        【マッチング募集】
        タイトル: \(post.title)
        内容: \(post.content)
        現在のメンバー: 男性\(post.hostGroupMale)人・女性\(post.hostGroupFemale)人
        募集人数: \(post.desiredGroupSize)人
        合流場所: \(post.meetupLocation)
        """
        
        let newMessage = ChatMessage(senderId: senderId,
                                     senderName: sender.nickname,
                                     senderIconUrl: sender.iconImageUrl,
                                     message: messageContent,
                                     timestamp: Date(),
                                     type: .matchingPost,
                                     matchingStatus: .active)
        
        do {
            try db.collection("chats").document(chatRoomId).collection("messages").addDocument(from: newMessage)
            print("Matching post sent successfully")
            self.latestMessageId = newMessage.id
        } catch {
            setError(error)
            print("Error sending matching post: \(error.localizedDescription)")
        }
    }
    
    func sendReply(to messageId: String, replyText: String, sender: UserProfile) {
        guard !sender.nickname.isEmpty else {
            setError(NSError(domain: "ChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Nickname is empty"]))
            return
        }
        guard let senderId = sender.id else {
            setError(NSError(domain: "ChatViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"]))
            return
        }
        
        let reply = Reply(id: UUID().uuidString,
                          senderId: senderId,
                          senderName: sender.nickname,
                          senderIconUrl: sender.iconImageUrl,
                          message: replyText,
                          timestamp: Date())
        
        db.collection("chats").document(chatRoomId).collection("messages").document(messageId).updateData([
            "replies": FieldValue.arrayUnion([try! Firestore.Encoder().encode(reply)])
        ]) { error in
            if let error = error {
                self.setError(error)
                print("Error sending reply: \(error.localizedDescription)")
            } else {
                print("Reply sent successfully")
            }
        }
    }
    
    func observeMessages(completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("chats").document(chatRoomId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.failure(NSError(domain: "ChatViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
                    return
                }
                
                self.messages = documents.compactMap { document -> ChatMessage? in
                    var message = try? document.data(as: ChatMessage.self)
                    if let statusString = document.data()["matchingStatus"] as? String {
                        message?.matchingStatus = MatchingStatus(rawValue: statusString)
                    }
                    return message
                }
                
                if let lastMessage = self.messages.last {
                    self.latestMessageId = lastMessage.id
                }
                
                completion(.success(()))
            }
    }
    
    private func setError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    func loadMatchingPostData(messageId: String, completion: @escaping (Result<(String, [Reply]), Error>) -> Void) {
        db.collection("chats").document(chatRoomId).collection("messages")
            .document(messageId).getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let content = data["message"] as? String else {
                    completion(.failure(NSError(domain: "ChatViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Matching post not found"])))
                    return
                }
                
                let replies = (data["replies"] as? [[String: Any]] ?? []).compactMap { replyData -> Reply? in
                    do {
                        return try Firestore.Decoder().decode(Reply.self, from: replyData)
                    } catch {
                        print("Error decoding reply: \(error)")
                        return nil
                    }
                }
                
                completion(.success((content, replies)))
            }
    }
    
    func updateMatchingStatus(messageId: String, status: MatchingStatus) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("chats")
            .document(chatRoomId)
            .collection("messages")
            .document(messageId)
            .getDocument { [weak self] document, error in
                guard let document = document,
                      let data = document.data(),
                      let senderId = data["senderId"] as? String else {
                    return
                }
                
                // Only allow the original poster to update the status
                if senderId == userId {
                    document.reference.updateData([
                        "matchingStatus": status.rawValue
                    ]) { error in
                        if let error = error {
                            self?.setError(error)
                        }
                    }
                }
            }
    }
    
    func closeMatchingPost(messageId: String) {
        updateMatchingStatus(messageId: messageId, status: .closed)
    }
}





