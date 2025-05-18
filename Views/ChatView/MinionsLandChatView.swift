//
//  MinionsLandChatView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/01.
//

import SwiftUI

struct MinionsLandChatView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: MainView.Tab
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("ミニオン・パーク オープンチャット")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "face.smiling")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                
                Text("ミニオンたちと楽しもう！")
                    .padding()
                
                Text("つくる")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                // ここにチャット機能を実装
                Spacer()
            }
            .navigationBarItems(trailing: Button("閉じる") {
                isPresented = false
            })
        }
        .overlay(
            VStack {
                Spacer()
                BottomMenuBar(selectedTab: $selectedTab)
            }
        )
    }
}

