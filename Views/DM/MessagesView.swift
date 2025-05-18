//
//  MessagesView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/16.
//

import SwiftUI
import Firebase
import Foundation
import Combine

struct MessagesView: View {
    @State private var selectedTab: MessagesTab = .matching
    @State private var selectedDMRoom: DMRoom?
    @State private var tabPosition: CGFloat = 0
    @State private var showDMRoom = false
    @StateObject private var dmRoomsViewModel = DMRoomsViewModel()
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    enum MessagesTab {
        case matching
        case messages
        
        var title: String {
            switch self {
            case .matching:
                return "マッチング"
            case .messages:
                return "メッセージ"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Spacer()
                Text("やりとり")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Image(systemName: "flag.fill")
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                    .padding(.trailing, 8)
                Button(action: {
                    // More actions
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.5))
                        .rotationEffect(.degrees(90))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach([MessagesTab.matching, MessagesTab.messages], id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? Color(red: 0.2, green: 0.2, blue: 0.5) : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
            }
            
            // Tab indicator
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / 2
                Rectangle()
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.5))
                    .frame(width: tabWidth, height: 2)
                    .offset(x: selectedTab == .matching ? 0 : tabWidth)
            }
            .frame(height: 2)
            
            Divider()
            
            // Tab content
            TabView(selection: $selectedTab) {
                MatchingTabView()
                    .tag(MessagesTab.matching)
                
                MessagesTabView(dmRoomsViewModel: dmRoomsViewModel, onTapDMRoom: { dmRoom in
                    selectedDMRoom = dmRoom
                    showDMRoom = true
                })
                .tag(MessagesTab.messages)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            if let userId = userProfileManager.userProfile?.id {
                dmRoomsViewModel.fetchDMRooms(for: userId)
            }
        }
        .sheet(isPresented: $showDMRoom) {
            if let dmRoom = selectedDMRoom,
               let currentUserId = userProfileManager.userProfile?.id {
                DMRoomView(roomId: dmRoom.id, currentUserId: currentUserId, partnerId: dmRoom.hostId == currentUserId ? dmRoom.guestId : dmRoom.hostId)
                    .environmentObject(userProfileManager)
            }
        }
    }
}

struct MatchingNotification: Identifiable {
    let id: String
    let userId: String
    let message: String
    let timestamp: Date
    let dmRoomId: String
}

struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY <= 0 {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 50)
                .onAppear {
                    if !isRefreshing {
                        isRefreshing = true
                        onRefresh()
                    }
                }
            } else {
                Color.clear.frame(height: 0)
            }
        }
        .frame(height: 50)
    }
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}



struct MatchingTabView: View {
    @State private var notifications: [MatchingNotification] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showIndexError = false
    @EnvironmentObject var userProfileManager: UserProfileManager
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                RefreshControl(isRefreshing: $isLoading, onRefresh: loadNotifications)
                
                LazyVStack(spacing: 0) {
                    if showIndexError {
                        IndexErrorView(onRetry: loadNotifications)
                    } else if let error = error {
                        ErrorView(error: error, onRetry: loadNotifications)
                    } else if notifications.isEmpty && !isLoading {
                        EmptyStateView()
                    } else {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(.top) // Added padding to the top
        .onAppear {
            loadNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .matchingResultReceived)) { notification in
            handleNewNotification(notification)
        }
    }
    
    private func loadNotifications() {
        guard let userId = userProfileManager.userProfile?.id else { return }
        isLoading = true
        error = nil
        showIndexError = false
        
        // First try with composite index
        let query = db.collection("matching_notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
        
        query.getDocuments { querySnapshot, error in
            if let error = error {
                // Check if the error is due to missing index
                if error.localizedDescription.contains("requires an index") {
                    showIndexError = true
                } else {
                    self.error = error
                }
                isLoading = false
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                isLoading = false
                return
            }
            
            let newNotifications = documents.compactMap { document -> MatchingNotification? in
                let data = document.data()
                guard let userId = data["userId"] as? String,
                      let message = data["message"] as? String,
                      let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                      let dmRoomId = data["dmRoomId"] as? String else {
                    return nil
                }
                
                return MatchingNotification(
                    id: document.documentID,
                    userId: userId,
                    message: message,
                    timestamp: timestamp,
                    dmRoomId: dmRoomId
                )
            }
            
            DispatchQueue.main.async {
                self.notifications = newNotifications
                self.isLoading = false
            }
        }
    }
    
    private func handleNewNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let userId = userInfo["userId"] as? String,
           let message = userInfo["message"] as? String,
           let timestamp = userInfo["timestamp"] as? Date,
           let dmRoomId = userInfo["dmRoomId"] as? String,
           userId == userProfileManager.userProfile?.id {
            let newNotification = MatchingNotification(
                id: UUID().uuidString,
                userId: userId,
                message: message,
                timestamp: timestamp,
                dmRoomId: dmRoomId
            )
            insertNotification(newNotification)
        }
    }
    
    private func insertNotification(_ notification: MatchingNotification) {
        DispatchQueue.main.async {
            if !self.notifications.contains(where: { $0.id == notification.id }) {
                self.notifications.insert(notification, at: 0)
            }
        }
    }
}

struct IndexErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("インデックスの作成が必要です")
                .font(.headline)
            
            Text("データベースのインデックスを作成する必要があります。以下の手順で作成してください：")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Firebase コンソールにアクセス")
                Text("2. Firestore Database > インデックス タブを選択")
                Text("3. 複合インデックスを作成")
                Text("4. コレクション: matching_notifications")
                Text("5. フィールド: userId (Ascending), timestamp (Descending)")
            }
            .font(.caption)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Button(action: onRetry) {
                Text("再試行")
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("エラーが発生しました")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: onRetry) {
                Text("再試行")
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("通知はありません")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}




struct NotificationRow: View {
    let notification: MatchingNotification
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                
                Text(formatDate(notification.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct MatchingRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("ユーザー名")
                    .font(.system(size: 16, weight: .medium))
                Text("マッチング待ち")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("12:34")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct MessageRow: View {
    let dmRoom: DMRoom
    let onTap: (DMRoom) -> Void
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var partnerProfile: UserProfile?
    @ObservedObject var dmRoomsViewModel: DMRoomsViewModel

    var body: some View {
        Button(action: {
            dmRoomsViewModel.markMessagesAsRead(for: dmRoom.id, userId: userProfileManager.userProfile?.id ?? "")
            onTap(dmRoom)
        }) {
            HStack(spacing: 12) {
                UserIconView(imageUrl: partnerProfile?.iconImageUrl, size: 60)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(partnerProfile?.nickname ?? "ユーザー名")
                        .font(.system(size: 16, weight: .medium))
                    Text(dmRoom.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatRelativeDate(dmRoom.lastMessageTimestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    if dmRoom.unreadCount > 0 {
                        Text("\(dmRoom.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadPartnerProfile()
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .weekOfYear, .year], from: date, to: now)
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "昨日"
        } else if let day = components.day, day < 7 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return formatter.string(from: date)
        }
    }
    
    private func loadPartnerProfile() {
        guard let currentUserId = userProfileManager.userProfile?.id else { return }
        let partnerId = dmRoom.hostId == currentUserId ? dmRoom.guestId : dmRoom.hostId
        
        userProfileManager.fetchUserProfile(userId: partnerId) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.partnerProfile = profile
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.partnerProfile = UserProfile(id: partnerId, nickname: "ユーザー\(partnerId.prefix(4))")
                }
            }
        }
    }
}






struct MessagesTabView: View {
    @ObservedObject var dmRoomsViewModel: DMRoomsViewModel
    let onTapDMRoom: (DMRoom) -> Void
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(dmRoomsViewModel.dmRooms) { dmRoom in
                    MessageRow(dmRoom: dmRoom, onTap: onTapDMRoom, dmRoomsViewModel: dmRoomsViewModel)
                    Divider()
                }
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .environmentObject(UserProfileManager())
    }
}

