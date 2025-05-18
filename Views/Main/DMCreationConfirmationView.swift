//
//  DMCreationConfirmationView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/16.
//

import SwiftUI

struct DMCreationConfirmationView: View {
    let partnerName: String
    @Binding var isPresented: Bool
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text("\(partnerName)さんとの")
                .font(.system(size: 18))
            Text("チャットルームを作成しました。")
                .font(.system(size: 18))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isPresented = false
                onDismiss()
            }
        }
    }
}




