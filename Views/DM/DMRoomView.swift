//
//  DMRoomView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct DMRoomView: View {
    let roomId: String
    let currentUserId: String
    let partnerId: String
    @StateObject private var viewModel: DMRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    init(roomId: String, currentUserId: String, partnerId: String) {
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.partnerId = partnerId
        self._viewModel = StateObject(wrappedValue: DMRoomViewModel(
            roomId: roomId,
            currentUserId: currentUserId,
            partnerId: partnerId
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                if let profile = viewModel.partnerProfile {
                    UserIconView(imageUrl: profile.iconImageUrl, size: 32)
                        .frame(width: 32, height: 32)
                    
                    Text(profile.nickname)
                        .font(.system(size: 16, weight: .medium))
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("Loading...")
                        .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "phone")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 10)
            .background(Color.white)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(groupMessagesByDate(viewModel.messages), id: \.date) { group in
                        VStack(spacing: 16) {
                            Text(formatDate(group.date))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            
                            ForEach(group.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == currentUserId,
                                    partnerProfile: viewModel.partnerProfile
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "camera")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                TextField("メッセージを入力", text: $messageText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                
                if !messageText.isEmpty {
                    Button(action: {
                        viewModel.sendMessage(messageText)
                        messageText = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private struct MessageGroup {
        let date: Date
        let messages: [DMMessage]
    }
    
    private func groupMessagesByDate(_ messages: [DMMessage]) -> [MessageGroup] {
        let grouped = Dictionary(grouping: messages) { message in
            Calendar.current.startOfDay(for: message.timestamp)
        }
        
        return grouped.map { (date, messages) in
            MessageGroup(date: date, messages: messages.sorted { $0.timestamp < $1.timestamp })
        }.sorted { $0.date < $1.date }
    }
}

struct MessageBubble: View {
    let message: DMMessage
    let isCurrentUser: Bool
    let partnerProfile: UserProfile?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isCurrentUser, let partnerProfile = partnerProfile {
                UserIconView(imageUrl: partnerProfile.iconImageUrl, size: 32)
                    .frame(width: 32, height: 32)
            } else if !isCurrentUser {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    if isCurrentUser {
                        Text(formatTime(message.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        Text(message.content)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    } else {
                        Text(message.content)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                        
                        Text(formatTime(message.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                }
            }
            .padding(isCurrentUser ? .leading : .trailing, isCurrentUser ? 60 : 0)
            
            if isCurrentUser {
                // Placeholder for user's icon if needed
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}







struct DMMessageView: View {
    let message: DMMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(10)
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if !isCurrentUser { Spacer() }
        }
    }
}

struct DMChatMessagesView: View {
    let messages: [DMMessage]
    let currentUserId: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    DMMessageView(message: message, isCurrentUser: message.senderId == currentUserId)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
        }
    }
}

struct PartnerProfileView: View {
    let partnerProfile: UserProfile?
    
    var body: some View {
        HStack {
            UserIconView(imageUrl: partnerProfile?.iconImageUrl)
                .frame(width: 32, height: 32)
            Text(partnerProfile?.nickname ?? "Unknown")
                .font(.headline)
        }
    }
}
