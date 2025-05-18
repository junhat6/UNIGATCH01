//
//  WizardingWorldChatView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/01.
//

import SwiftUI

struct WizardingWorldChatView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: MainView.Tab
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("ウィザーディング・ワールド・オブ・ハリー・ポッター オープンチャット")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 48))
                    .foregroundColor(.purple)
                
                Text("魔法の世界で冒険しよう！")
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

