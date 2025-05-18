//
//  DMRoomsViewModel.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/17.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class DMRoomsViewModel: ObservableObject {
    @Published var dmRooms: [DMRoom] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    func fetchDMRooms(for userId: String) {
        listenerRegistration?.remove()
        
        let query = db.collection("dm_rooms")
            .whereFilter(Filter.orFilter([
                Filter.whereField("hostId", isEqualTo: userId),
                Filter.whereField("guestId", isEqualTo: userId)
            ]))


        listenerRegistration = query.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DMルームの取得エラー: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }

            self?.dmRooms = documents.compactMap { document -> DMRoom? in
                let data = document.data()
                let id = document.documentID
                let hostId = data["hostId"] as? String ?? ""
                let guestId = data["guestId"] as? String ?? ""
                let lastMessage = data["lastMessage"] as? String ?? ""
                let lastMessageTimestamp = (data["lastMessageTimestamp"] as? Timestamp)?.dateValue() ?? Date()
                let lastMessageSenderId = data["lastMessageSenderId"] as? String ?? ""
                let unreadCount = data["unreadCount"] as? Int ?? 0
                
                return DMRoom(id: id, hostId: hostId, guestId: guestId, lastMessage: lastMessage, lastMessageTimestamp: lastMessageTimestamp, lastMessageSenderId: lastMessageSenderId, unreadCount: unreadCount)
            }
        }
    }

    func markMessagesAsRead(for roomId: String, userId: String) {
        FirestoreManager.shared.markMessagesAsRead(roomId: roomId, userId: userId) { error in
            if let error = error {
                print("Error marking messages as read: \(error.localizedDescription)")
            } else {
                print("Messages marked as read successfully")
                self.fetchDMRooms(for: userId)
            }
        }
    }

    deinit {
        listenerRegistration?.remove()
    }
}

struct DMRoom: Identifiable {
    let id: String
    let hostId: String
    let guestId: String
    let lastMessage: String
    let lastMessageTimestamp: Date
    let lastMessageSenderId: String
    let unreadCount: Int
}

