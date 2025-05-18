//
//  ChatMessageView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    @Binding var showReplyInput: Bool
    @Binding var selectedMessageId: String?
    var onReply: (String) -> Void
    var onDMCreation: (String) -> Void
    var onUserTap: (String) -> Void
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var showReplies = false
    @State private var isShowingSheet = false // 状態変数を追加
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                if !isCurrentUser {
                    UserIconView(imageUrl: message.senderIconUrl)
                        .onTapGesture {
                            onUserTap(message.senderId)
                        }
                } else {
                    Spacer()
                }
                
                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if message.type == .matchingPost {
                        MatchingPostCard(message: message)
                        
                        // Only show action buttons if the post is not closed
                        if message.matchingStatus != .closed {
                            HStack(spacing: 12) {
                                Button(action: {
                                    selectedMessageId = message.id  // バインディングを更新
                                    showReplyInput = true  // バインディングを更新
                                    onReply(message.id ?? "")
                                }) {
                                    Label("返信", systemImage: "arrowshape.turn.up.left")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                if isCurrentUser && !message.replies.isEmpty {
                                    Button {
                                        if let messageId = message.id {
                                            onDMCreation(messageId)
                                            print("DM Button Tapped: \(messageId)") // デバッグ用
                                        } else {
                                            print("Error: message.id is nil") // エラーログ
                                        }
                                    } label: {
                                        Label("DM", systemImage: "message")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                if !message.replies.isEmpty {
                                    Button(action: { showReplies.toggle() }) {
                                        Label(showReplies ? "返信を隠す" : "返信を表示", systemImage: "text.bubble")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    } else {
                        Text(message.message)
                            .padding(10)
                            .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                
                if isCurrentUser {
                    UserIconView(imageUrl: userProfileManager.userProfile?.iconImageUrl)
                        .onTapGesture {
                            onUserTap(message.senderId)
                        }
                } else {
                    Spacer()
                }
            }
            
            if showReplies {
                VStack(spacing: 8) {
                    ForEach(message.replies) { reply in
                        ReplyView(reply: reply, isCurrentUser: reply.senderId == userProfileManager.userProfile?.id)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .padding(.horizontal)
    }
}

struct MatchingPostCard: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("マッチング募集")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
                
                if let status = message.matchingStatus {
                    HStack(spacing: 4) {
                        Image(systemName: status.icon)
                        Text(status.rawValue)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.color)
                    .cornerRadius(4)
                    
                    Text(message.formattedTimestamp())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            
            let messageLines = message.message.components(separatedBy: "\n")
            VStack(alignment: .leading, spacing: 4) {
                ForEach(message.message.components(separatedBy: "\n"), id: \.self) { line in
                    if let colonIndex = line.firstIndex(of: ":") {
                        HStack(spacing: 4) {
                            Text(String(line[..<colonIndex]) + ":")
                                .fontWeight(.bold)
                                .font(.system(size: UIScreen.main.bounds.width < 380 ? 13 : 14))
                            Text(String(line[line.index(after: colonIndex)...]))
                                .font(.system(size: UIScreen.main.bounds.width < 380 ? 13 : 14))
                        }
                    } else {
                        Text(line)
                            .font(.system(size: UIScreen.main.bounds.width < 380 ? 13 : 14))
                    }
                }
            }
            
            HStack(spacing: 16) {

                HStack(spacing: 4) {

                    HStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        Text("\(extractNumber(from: message.message, prefix: "男性"))人")
                            .font(.system(size: UIScreen.main.bounds.width < 380 ? 12 : 14))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    

                    HStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        Text("\(extractNumber(from: message.message, prefix: "女性"))人")
                            .font(.system(size: UIScreen.main.bounds.width < 380 ? 12 : 14))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(12)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                    Text("募集:\(extractNumber(from: message.message, prefix: "募集人数:"))")
                        .font(.system(size: UIScreen.main.bounds.width < 380 ? 12 : 14))
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(message.matchingStatus?.color ?? Color.green, lineWidth: 1)
        )
        .opacity(message.matchingStatus == .closed ? 0.6 : 1.0)
    }
    
    private func extractNumber(from text: String, prefix: String) -> String {
        // Split the text into lines
        let lines = text.components(separatedBy: "\n")
        
        // Find the line containing our prefix
        if let targetLine = lines.first(where: { $0.contains(prefix) }) {
            // For 募集人数, look for the specific format
            if prefix == "募集人数:" {
                if let range = targetLine.range(of: "募集人数: ") {
                    let afterPrefix = targetLine[range.upperBound...]
                    let numberEndIndex = afterPrefix.firstIndex(where: { !$0.isNumber }) ?? afterPrefix.endIndex
                    let number = String(afterPrefix[..<numberEndIndex])
                    return number.isEmpty ? "0" : number
                }
            }
            
            // For other prefixes (男性, 女性)
            if let range = targetLine.range(of: prefix) {
                let afterPrefix = targetLine[range.upperBound...]
                let numberEndIndex = afterPrefix.firstIndex(where: { !$0.isNumber }) ?? afterPrefix.endIndex
                let number = String(afterPrefix[..<numberEndIndex])
                return number.isEmpty ? "0" : number
            }
        }
        return "0"
    }
    
    private func extractLocation(from text: String) -> String {
        guard let range = text.range(of: "合流場所:") else { return "N/A" }
        let startIndex = text.index(range.upperBound, offsetBy: 1)
        let endIndex = text[startIndex...].firstIndex(of: "\n") ?? text.endIndex
        return String(text[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
    }
}





struct ReplyView: View {
    let reply: Reply
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !isCurrentUser {
                UserIconView(imageUrl: reply.senderIconUrl)
            } else {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(reply.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(reply.message)
                    .padding(8)
                    .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            if isCurrentUser {
                UserIconView(imageUrl: reply.senderIconUrl)
            } else {
                Spacer()
            }
        }
    }
}












