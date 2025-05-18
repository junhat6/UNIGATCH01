//
//  MessageInputView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    var onSend: () -> Void
    var onMatchingPost: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onMatchingPost) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
            }
            .padding(.leading)
            
            TextField("メッセージを入力", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                onSend()
                messageText = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .background(Color.white)
        .shadow(radius: 1)
        .padding(.bottom, 30)
    }
}






