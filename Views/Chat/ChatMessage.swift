//
//  ChatMessage.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import Foundation
import FirebaseFirestore
import SwiftUICore


enum MatchingStatus: String, Codable {
    case active = "募集中"
    case matched = "マッチング成立"
    case closed = "募集終了"
    
    var color: Color {
        switch self {
        case .active:
            return .green
        case .matched:
            return .blue
        case .closed:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .active:
            return "person.2.fill"
        case .matched:
            return "checkmark.circle.fill"
        case .closed:
            return "xmark.circle.fill"
        }
    }
}

struct ChatMessage: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let senderId: String
    let senderName: String
    let senderIconUrl: String?
    let message: String
    let timestamp: Date
    let type: MessageType
    var replies: [Reply] = []
    var matchingStatus: MatchingStatus? // New field for matching status
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case senderName
        case senderIconUrl
        case message
        case timestamp
        case type
        case replies
        case matchingStatus
    }
    
    enum MessageType: String, Codable {
        case normal
        case matchingPost
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.senderId == rhs.senderId &&
               lhs.senderName == rhs.senderName &&
               lhs.senderIconUrl == rhs.senderIconUrl &&
               lhs.message == rhs.message &&
               lhs.timestamp == rhs.timestamp &&
               lhs.type == rhs.type &&
               lhs.replies == rhs.replies &&
               lhs.matchingStatus == rhs.matchingStatus
    }
    
    func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: timestamp, to: now)
        
        if let days = components.day, days > 0 {
            formatter.dateFormat = "M月d日"
            return formatter.string(from: timestamp)
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)時間前"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)分前"
        } else {
            return "たった今"
        }
    }
}





struct Reply: Identifiable, Codable, Equatable {
    let id: String
    let senderId: String
    let senderName: String
    let senderIconUrl: String?
    let message: String
    let timestamp: Date
    
    static func == (lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id &&
               lhs.senderId == rhs.senderId &&
               lhs.senderName == rhs.senderName &&
               lhs.senderIconUrl == rhs.senderIconUrl &&
               lhs.message == rhs.message &&
               lhs.timestamp == rhs.timestamp
    }
}




