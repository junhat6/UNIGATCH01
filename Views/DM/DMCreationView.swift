//
//  DMCreationView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/08.
//

import SwiftUI
import FirebaseFirestore

struct DMCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DMCreationViewModel
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Binding var showSuperNintendoWorldChat: Bool
    @Binding var selectedTab: MainView.Tab
    
    init(matchingPostId: String, preloadedContent: String, preloadedReplies: [Reply], showSuperNintendoWorldChat: Binding<Bool>, selectedTab: Binding<MainView.Tab>) {
        print("DMCreationView init - matchingPostId: \(matchingPostId)")
        print("Preloaded content: \(preloadedContent)")
        print("Number of preloaded replies: \(preloadedReplies.count)")
        self._viewModel = StateObject(wrappedValue: DMCreationViewModel(matchingPostId: matchingPostId, preloadedContent: preloadedContent, preloadedReplies: preloadedReplies))
        self._showSuperNintendoWorldChat = showSuperNintendoWorldChat
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    originalPostCard
                    repliesList
                }
                .padding()
            }
            .navigationTitle("DM相手を選択")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("キャンセル") {
                dismiss()
            })
        }
        .onAppear {
            print("DMCreationView appeared")
            print("Original post content: \(viewModel.originalPostContent)")
            print("Number of replies: \(viewModel.replies.count)")
        }
    }
    
    private var originalPostCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("元の投稿")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.originalPostContent)
                .font(.body)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var repliesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("返信")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if viewModel.replies.isEmpty {
                Text("返信はありません")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(viewModel.replies) { reply in
                    Button(action: {
                        createDMRoom(with: reply.senderId, partnerName: reply.senderName)
                    }) {
                        replyCard(reply: reply)
                    }
                }
            }
        }
    }
    
    private func replyCard(reply: Reply) -> some View {
        HStack(spacing: 12) {
            UserIconView(imageUrl: reply.senderIconUrl, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reply.senderName)
                    .font(.headline)
                Text(reply.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func createDMRoom(with userId: String, partnerName: String) {
        guard let currentUserId = userProfileManager.userProfile?.id else {
            print("⚠️ Error: Current user ID not found")
            return
        }
        
        print("🚀 Starting to create DM room...")
        viewModel.createDMRoom(hostId: currentUserId, guestId: userId, matchingPostContent: viewModel.originalPostContent) { result in
            switch result {
            case .success(let dmRoomId):
                print("✅ DM room created with ID: \(dmRoomId)")
                DispatchQueue.main.async {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(name: .dmRoomCreated, object: nil, userInfo: ["dmRoomId": dmRoomId, "partnerId": userId, "partnerName": partnerName])
                    }
                }
            case .failure(let error):
                print("❌ Error creating DM room: \(error.localizedDescription)")
            }
        }
    }
}





