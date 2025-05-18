//
//  BottomMenuBar.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/01.
//

import SwiftUI

struct BottomMenuBar: View {
    @Binding var selectedTab: MainView.Tab
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                menuButton(tab: .home, imageName: "map", text: "ホーム")
                Spacer()
                menuButton(tab: .discover, imageName: "magnifyingglass", text: "見つける")
                Spacer()
                menuButton(tab: .create, imageName: "plus.circle.fill", text: "つくる")
                Spacer()
                menuButton(tab: .messages, imageName: "message", text: "やりとり")
                Spacer()
                menuButton(tab: .profile, imageName: "person", text: "プロフィール")
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            Rectangle()
                .fill(Color.clear)
                .frame(height: 20) // SafeAreaの下に余白を追加
        }
        .background(Color.white.shadow(radius: 2))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func menuButton(tab: MainView.Tab, imageName: String, text: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                Text(text)
                    .font(.system(size: 10))
            }
        }
        .foregroundColor(selectedTab == tab ? .red : .gray)
    }
}


