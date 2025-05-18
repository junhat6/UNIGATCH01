//
//  SuperNintendoWorldChatView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/01.
//

import Combine
import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SuperNintendoWorldChatViewModel: ObservableObject {
    @Published var participantCount: Int = 0
    @Published var error: Error?
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var uniqueSenders: Set<String> = []
    
    init() {
        updateParticipantCount()
    }
    
    func updateParticipantCount() {
        let chatRoomRef = db.collection("chats").document("super_nintendo_world")
        let messagesRef = chatRoomRef.collection("messages")
        
        listenerRegistration = messagesRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("メッセージの取得エラー: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }
            
            self?.uniqueSenders.removeAll()
            
            for document in documents {
                if let senderId = document.data()["senderId"] as? String {
                    self?.uniqueSenders.insert(senderId)
                }
            }
            
            DispatchQueue.main.async {
                self?.participantCount = self?.uniqueSenders.count ?? 0
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}

struct ChatHeader: View {
    @Binding var isPresented: Bool
    let participantCount: Int
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                    Image(systemName: "gamecontroller")
                        .foregroundColor(.green)
                }
            }
            .accessibilityLabel("戻る")
            
            Text("スーパー・ニンテンドー・ワールド")
                .font(.headline)
            Spacer()
            Text("\(participantCount)人参加中")
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
    }
}

struct ChatInputView: View {
    @Binding var messageText: String
    var onSend: () -> Void
    var onMatchingPost: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMatchingPost) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
            }
            .accessibilityLabel("マッチング投稿")
            .padding(.leading, 16)  // 左端のパディングを増やす
            
            TextField("メッセージを入力", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 8)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .disabled(messageText.isEmpty)
            .accessibilityLabel("送信")
            .padding(.trailing, 16)  // 右端のパディングを増やす
        }
        .padding(.vertical, 12)  // 上下のパディングを増やす
        .background(Color.white)
        .shadow(radius: 1)
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    @Binding var showReplyInput: Bool
    @Binding var selectedMessageId: String?
    let onReply: (String) -> Void
    let onDMCreation: (String) -> Void
    let onUserTap: (String) -> Void
    
    var body: some View {
        ChatMessageView(
            message: message,
            isCurrentUser: isCurrentUser,
            showReplyInput: $showReplyInput,
            selectedMessageId: $selectedMessageId,
            onReply: { _ in
                onReply(message.id ?? "")
            },
            onDMCreation: { _ in
                onDMCreation(message.id ?? "")
            },
            onUserTap: onUserTap
        )
    }
}

// ★ 修正ポイント: ScrollViewReader + onChange(of: latestMessageId) で自動スクロール
struct ChatMessagesView: View {
    @ObservedObject var viewModel: ChatViewModel
    @EnvironmentObject var userProfileManager: UserProfileManager
    var onReply: (String) -> Void
    var onDMCreation: (String) -> Void
    var onUserTap: (String) -> Void
    
    // 最新メッセージIDを受け取るバインディング
    @Binding var latestMessageId: String?
    
    // 返信用
    @Binding var showReplyInput: Bool
    @Binding var selectedMessageId: String?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        ChatMessageRow(
                            message: message,
                            isCurrentUser: message.senderId == userProfileManager.userProfile?.id,
                            showReplyInput: $showReplyInput,
                            selectedMessageId: $selectedMessageId,
                            onReply: onReply,
                            onDMCreation: onDMCreation,
                            onUserTap: onUserTap
                        )
                        .id(message.id)  // ← スクロール先を識別するために ID を付与
                    }
                }
            }
            // latestMessageId の値が変わるたびに一番下へスクロール
            .onChange(of: latestMessageId) { newValue, oldValue in
                guard let newValue = newValue else { return }
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .bottom)
                }
            }
        }
    }
}

struct ChatContent: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var chatViewModel: SuperNintendoWorldChatViewModel
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Binding var messageText: String
    @Binding var showMatchingPostView: Bool
    @Binding var showReplyInput: Bool
    @Binding var selectedMessageId: String?
    @Binding var selectedMessage: ChatMessage?
    @Binding var latestMessageId: String?
    @Binding var showDMCreation: Bool
    @Binding var selectedMatchingPostId: String?
    @Binding var showError: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var preloadedMatchingPostData: (content: String, replies: [Reply])?
    @Binding var isPresented: Bool
    @Binding var selectedTab: MainView.Tab
    @Binding var selectedUserId: String?
    @Binding var showUserProfile: Bool

    var body: some View {
        VStack {
            ChatMessagesView(
                viewModel: viewModel,
                userProfileManager: _userProfileManager,
                onReply: handleReply,
                onDMCreation: handleDMCreation,
                onUserTap: handleUserTap,
                latestMessageId: $latestMessageId,
                showReplyInput: $showReplyInput,
                selectedMessageId: $selectedMessageId
            )

            VStack {
                ChatInputView(
                    messageText: $messageText,
                    onSend: {
                        if let userProfile = userProfileManager.userProfile {
                            viewModel.sendMessage(messageText, sender: userProfile)
                            messageText = ""
                        }
                    },
                    onMatchingPost: {
                        showMatchingPostView = true
                    }
                )
            }
            .background(Color.white)
            .padding(.bottom, max(keyboardHeight, 16))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }

    private func handleReply(_ messageId: String) {
        if let message = viewModel.messages.first(where: { $0.id == messageId }) {
            selectedMessageId = messageId
            selectedMessage = message
            showReplyInput = true
        }
    }

    private func handleDMCreation(_ messageId: String) {
        print("Handling DM creation for message ID: \(messageId)")
        viewModel.loadMatchingPostData(messageId: messageId) { result in
            switch result {
            case .success(let data):
                print("Successfully loaded matching post data")
                self.preloadedMatchingPostData = data
                self.selectedMatchingPostId = messageId
                DispatchQueue.main.async {
                    self.showDMCreation = true
                }
            case .failure(let error):
                print("Error loading matching post data: \(error.localizedDescription)")
                self.showError = true
            }
        }
    }

    private func handleUserTap(_ userId: String) {
        selectedUserId = userId
        showUserProfile = true
    }
}

struct SuperNintendoWorldChatView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: MainView.Tab
    @StateObject private var viewModel = ChatViewModel(chatRoomId: "super_nintendo_world")
    @StateObject private var chatViewModel = SuperNintendoWorldChatViewModel()
    @State private var messageText = ""
    @State private var showMatchingPostView = false
    @State private var showReplyInput = false
    @State private var selectedMessageId: String?
    @State private var selectedMessage: ChatMessage?
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var isUserAuthenticated = false
    @State private var latestMessageId: String?
    @State private var showDMCreation = false
    @State private var selectedMatchingPostId: String?
    @State private var showError = false
    @State private var isProfileLoaded = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showDMRoom = false
    @State private var dmRoomViewData: (roomId: String, partnerId: String)? = nil
    @State private var showDMCreationConfirmation = false
    @State private var dmPartnerName = ""
    @State private var preloadedMatchingPostData: (content: String, replies: [Reply])?
    @State private var showUserProfile = false
    @State private var selectedUserId: String?

    var body: some View {
        VStack(spacing: 0) {
            ChatHeader(isPresented: $isPresented, participantCount: chatViewModel.participantCount)
            
            if isProfileLoaded {
                ChatContent(
                    viewModel: viewModel,
                    chatViewModel: chatViewModel,
                    userProfileManager: _userProfileManager,
                    messageText: $messageText,
                    showMatchingPostView: $showMatchingPostView,
                    showReplyInput: $showReplyInput,
                    selectedMessageId: $selectedMessageId,
                    selectedMessage: $selectedMessage,
                    latestMessageId: $latestMessageId,
                    showDMCreation: $showDMCreation,
                    selectedMatchingPostId: $selectedMatchingPostId,
                    showError: $showError,
                    keyboardHeight: $keyboardHeight,
                    preloadedMatchingPostData: $preloadedMatchingPostData,
                    isPresented: $isPresented,
                    selectedTab: $selectedTab,
                    selectedUserId: $selectedUserId,
                    showUserProfile: $showUserProfile
                )
            } else {
                ProgressView("プロフィールを読み込んでいます...")
            }
        }
        .background(Color.white)
        .onAppear(perform: onAppear)
        // メッセージが更新されたら最新メッセージIDを更新する
        .onReceive(viewModel.$messages, perform: onReceiveMessages)
        .sheet(isPresented: $showMatchingPostView, content: matchingPostSheet)
        .sheet(isPresented: $showReplyInput, content: replyInputSheet)
        .sheet(isPresented: $showDMCreation, content: dmCreationSheet)
        .sheet(isPresented: $showUserProfile, content: userProfileSheet)
        .alert(isPresented: $showError, content: errorAlert)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: keyboardWillShow)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: keyboardWillHide)
        .onReceive(NotificationCenter.default.publisher(for: .dismissSuperNintendoWorldChat), perform: dismissChat)
        .onReceive(NotificationCenter.default.publisher(for: .dmRoomCreated), perform: handleDMRoomCreated)
        .onAppear {
            print("SuperNintendoWorldChatView appeared")
        }
        .onChange(of: showReplyInput) { oldValue, newValue in
            print("showReplyInput changed from \(oldValue) to \(newValue)")
            print("selectedMessage: \(String(describing: selectedMessage))")
        }
    }
    
    private func replyInputSheet() -> some View {
        Group {
            if let message = selectedMessage {
                ReplyInputView(
                    isPresented: $showReplyInput,
                    originalPost: message.message,
                    onSendReply: { replyText in
                        if let userProfile = userProfileManager.userProfile {
                            viewModel.sendReply(to: selectedMessageId ?? "", replyText: replyText, sender: userProfile)
                        }
                    }
                )
            } else {
                Text("返信する投稿が選択されていません")
            }
        }
    }

    private func onAppear() {
        viewModel.observeMessages { result in
            switch result {
            case .success:
                print("Messages loaded successfully")
            case .failure(let error):
                print("Error loading messages: \(error.localizedDescription)")
                showError = true
            }
        }
        checkAuthentication()
        loadUserProfile()
    }

    private func onReceiveMessages(_ messages: [ChatMessage]) {
        // 最新メッセージの ID をバインディングに反映して、ChatMessagesView で自動スクロールさせる
        if let lastMessage = messages.last {
            latestMessageId = lastMessage.id
        }
    }

    private func matchingPostSheet() -> some View {
        NavigationView {
            MatchingPostView(isPresented: $showMatchingPostView) { post in
                if let userProfile = userProfileManager.userProfile {
                    viewModel.sendMatchingPost(post, sender: userProfile)
                }
            }
        }
    }

    private func dmCreationSheet() -> some View {
        Group {
            if let postId = selectedMatchingPostId,
               let preloadedData = preloadedMatchingPostData {
                DMCreationView(
                    matchingPostId: postId,
                    preloadedContent: preloadedData.content,
                    preloadedReplies: preloadedData.replies,
                    showSuperNintendoWorldChat: $isPresented,
                    selectedTab: $selectedTab
                )
                .environmentObject(userProfileManager)
            } else {
                Text("データの読み込みに失敗しました")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            print("DM Creation sheet appeared")
            print("Selected matching post ID: \(selectedMatchingPostId ?? "nil")")
            print("Preloaded data: \(preloadedMatchingPostData != nil ? "available" : "nil")")
        }
    }

    private func userProfileSheet() -> some View {
        NavigationView {
            if let userId = selectedUserId {
                UserProfileView(userId: userId)
            } else {
                EmptyView()
            }
        }
    }

    private func errorAlert() -> Alert {
        Alert(
            title: Text("エラー"),
            message: Text(viewModel.error?.localizedDescription ?? "不明なエラーが発生しました"),
            primaryButton: .default(Text("再試行")) {
                loadUserProfile()
                viewModel.observeMessages { _ in }
            },
            secondaryButton: .cancel(Text("閉じる"))
        )
    }

    private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }

    private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
    }

    private func dismissChat(_ notification: Notification) {
        showDMCreationConfirmation = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
            selectedTab = .messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .switchToMessagesTab, object: nil)
            }
        }
    }

    private func handleDMRoomCreated(_ notification: Notification) {
        if let dmRoomId = notification.userInfo?["dmRoomId"] as? String,
           let partnerId = notification.userInfo?["partnerId"] as? String,
           let partnerName = notification.userInfo?["partnerName"] as? String {
            isPresented = false
            selectedTab = .messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .openDMRoom, object: nil, userInfo: [
                    "dmRoomId": dmRoomId,
                    "partnerId": partnerId,
                    "partnerName": partnerName
                ])
            }
        }
    }

    private func checkAuthentication() {
        if let user = Auth.auth().currentUser {
            isUserAuthenticated = true
            print("認証されたユーザーID: \(user.uid)")
        } else {
            isUserAuthenticated = false
            print("ユーザーは認証されていません")
        }
    }

    private func loadUserProfile() {
        userProfileManager.loadUserProfile { result in
            switch result {
            case .success:
                self.isProfileLoaded = true
                print("User profile loaded successfully. ID: \(self.userProfileManager.userProfile?.id ?? "nil")")
            case .failure(let error):
                print("Error loading user profile: \(error.localizedDescription)")
                self.showError = true
            }
        }
    }
    
    private func handleReply(_ messageId: String) {
        selectedMessageId = messageId
        showReplyInput = true
    }
}
