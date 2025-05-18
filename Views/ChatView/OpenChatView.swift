//
//  OpenChatView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/01.
//

import SwiftUI

struct OpenChatView: View {
    let area: USJArea
    @State private var showAreaSpecificChat = false
    @Binding var selectedTab: MainView.Tab
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userProfileManager: UserProfileManager  // UserProfileManagerに変更
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ScrollView {
                    VStack {
                        Text("\(area.name)のオープンチャット")
                            .font(.title)
                        Image(systemName: area.icon)
                            .font(.system(size: 48))
                            .foregroundColor(area.color)
                        
                        Button(action: {
                            showAreaSpecificChat = true
                        }) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                Text("エリア専用チャットを開く")
                            }
                            .padding()
                            .background(area.color)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        
                        Text("アトラクション:")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(area.attractions) { attraction in
                            Text(attraction.name)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                }
                .navigationBarItems(trailing: Button("閉じる") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            
            BottomMenuBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showAreaSpecificChat) {
            switch area.name {
            case "スーパー・ニンテンドー・ワールド":
                SuperNintendoWorldChatView(isPresented: $showAreaSpecificChat, selectedTab: $selectedTab)
                    .environmentObject(userProfileManager)  // UserProfileManagerを渡す
            case "ウィザーディング・ワールド・オブ・ハリー・ポッター":
                WizardingWorldChatView(isPresented: $showAreaSpecificChat, selectedTab: $selectedTab)
                    .environmentObject(userProfileManager) // UserProfileManagerを渡す
            case "ミニオン・パーク":
                MinionsLandChatView(isPresented: $showAreaSpecificChat, selectedTab: $selectedTab)
                    .environmentObject(userProfileManager) // UserProfileManagerを渡す
            default:
                Text("このエリアの専用チャットは準備中です。")
            }
        }
    }
}





