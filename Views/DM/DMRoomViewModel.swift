//
//  DMRoomViewModel.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DMMessage: Identifiable, Codable {
    var id: String?
    let content: String
    let senderId: String
    let senderName: String
    let senderIconUrl: String?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case senderId
        case senderName
        case senderIconUrl
        case timestamp
    }
}

class DMRoomViewModel: ObservableObject {
    @Published var messages: [DMMessage] = []
    @Published var partnerProfile: UserProfile?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var isPartnerProfileLoaded = false

    let currentUserId: String
    private let roomId: String
    private let partnerId: String
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init(roomId: String, currentUserId: String, partnerId: String) {
        print("DMRoomViewModel initialized with roomId: \(roomId), currentUserId: \(currentUserId), partnerId: \(partnerId)")
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.partnerId = partnerId

        isLoading = true
        loadPartnerProfile()
        observeMessages()
        markMessagesAsRead()
    }

    private func loadPartnerProfile() {
        print("Loading partner profile for userId: \(partnerId)")

        db.collection("user_profiles").document(partnerId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error loading partner profile: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                    self.isPartnerProfileLoaded = true
                }
                return
            }

            if let data = snapshot?.data() {
                print("📄 Retrieved user data: \(data)")
                let profile = UserProfile(
                    id: data["id"] as? String ?? self.partnerId,
                    nickname: data["nickname"] as? String ?? "Unknown",
                    gender: data["gender"] as? String ?? "",
                    age: data["age"] as? String ?? "",
                    residence: data["residence"] as? String ?? "",
                    occupation: data["occupation"] as? String ?? "",
                    height: data["height"] as? String ?? "",
                    purpose: data["purpose"] as? String ?? "",
                    annualPass: data["annual_pass"] as? String ?? "",
                    thrillRide: data["thrill_ride"] as? String ?? "",
                    favoriteAttraction: data["favorite_attraction"] as? String ?? "",
                    favoriteArea: data["favorite_area"] as? String ?? "",
                    favoriteCharacter: data["favorite_character"] as? String ?? "",
                    imageUrl: data["image_url"] as? String,
                    introduction: data["introduction"] as? String,
                    iconImageUrl: data["icon_image_url"] as? String
                )

                if profile.nickname.isEmpty {
                    profile.nickname = "ゲスト\(String(self.partnerId.prefix(4)))"
                }

                print("✅ Successfully decoded profile: \(profile.nickname)")
                DispatchQueue.main.async {
                    self.partnerProfile = profile
                    self.isLoading = false
                    self.isPartnerProfileLoaded = true
                }
            } else {
                print("❌ No user data found for partnerId: \(partnerId)")
                DispatchQueue.main.async {
                    let defaultProfile = UserProfile(id: self.partnerId, nickname: "Unknown User")
                    self.partnerProfile = defaultProfile
                    self.isLoading = false
                    self.isPartnerProfileLoaded = true
                }
            }
        }
    }

    private func observeMessages() {
        print("🔍 Starting to observe messages for room: \(roomId)")
        isLoading = true

        let messagesRef = db.collection("dm_rooms").document(roomId).collection("messages")
        print("📁 Messages collection path: \(messagesRef.path)")

        listenerRegistration = messagesRef
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error observing messages: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.error = error
                        self.isLoading = false
                    }
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("⚠️ No messages documents found")
                    DispatchQueue.main.async {
                        self.messages = []
                        self.isLoading = false
                    }
                    return
                }

                print("📝 Found \(documents.count) messages")

                self.messages = documents.compactMap { document -> DMMessage? in
                    let data = document.data()
                    let message = DMMessage(
                        id: document.documentID,
                        content: data["content"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        senderName: data["senderName"] as? String ?? "Unknown",
                        senderIconUrl: data["senderIconUrl"] as? String,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    print("✅ Successfully decoded message: \(message.content)")
                    return message
                }

                print("📊 Final messages count: \(self.messages.count)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
    }

    func sendMessage(_ content: String) {
        print("Attempting to send message: \(content)")
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Message content is empty")
            return
        }

        let message = DMMessage(
            id: nil,
            content: content,
            senderId: currentUserId,
            senderName: UserDefaults.standard.string(forKey: "userName") ?? "Unknown",
            senderIconUrl: UserDefaults.standard.string(forKey: "userIconUrl"),
            timestamp: Date()
        )

        var messageData: [String: Any] = [
            "content": message.content,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let senderIconUrl = message.senderIconUrl {
            messageData["senderIconUrl"] = senderIconUrl
        }

        db.collection("dm_rooms").document(roomId).collection("messages").addDocument(data: messageData) { [weak self] error in
            if let error = error {
                print("❌ Error sending message: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.error = error
                }
            } else {
                print("Message sent successfully")
                self?.updateDMRoomLastMessage(content: content, senderId: message.senderId)
                if let roomId = self?.roomId, let currentUserId = self?.currentUserId {
                    FirestoreManager.shared.sendPushNotification(roomId: roomId, message: content, senderId: currentUserId)
                }
            }
        }
    }

    private func updateDMRoomLastMessage(content: String, senderId: String) {
        FirestoreManager.shared.updateDMRoomLastMessage(roomId: roomId, message: content, senderId: senderId) { error in
            if let error = error {
                print("❌ Error updating DM room last message: \(error.localizedDescription)")
            } else {
                print("DM room last message updated successfully")
            }
        }
    }
    
    private func markMessagesAsRead() {
        FirestoreManager.shared.markMessagesAsRead(roomId: roomId, userId: currentUserId) { error in
            if let error = error {
                print("Error marking messages as read: \(error.localizedDescription)")
            } else {
                print("Messages marked as read successfully")
            }
        }
    }

    deinit {
        print("DMRoomViewModel deinitializing")
        listenerRegistration?.remove()
    }
}





