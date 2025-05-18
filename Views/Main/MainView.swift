//
//  MainView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/11.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @State private var showStartView = false
    @State private var showSuperNintendoWorldChat = false

    enum Tab {
        case home, discover, create, messages, profile
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab, showSuperNintendoWorldChat: $showSuperNintendoWorldChat)
                    .tabItem {
                        Label("ホーム", systemImage: "house")
                    }
                    .tag(Tab.home)
                
                Text("見つける")
                    .tabItem {
                        Label("見つける", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.discover)
                
                Text("つくる")
                    .tabItem {
                        Label("つくる", systemImage: "plus.circle")
                    }
                    .tag(Tab.create)
                
                MessagesView()
                    .tabItem {
                        Label("やりとり", systemImage: "message")
                    }
                    .tag(Tab.messages)
                
                ProfileView(showStartView: $showStartView)
                    .tabItem {
                        Label("プロフィール", systemImage: "person")
                    }
                    .tag(Tab.profile)
            }
            .tint(.red)
            
            if showSuperNintendoWorldChat {
                SuperNintendoWorldChatView(isPresented: $showSuperNintendoWorldChat, selectedTab: $selectedTab)
                    .transition(.move(edge: .trailing))
                    .animation(.spring(), value: showSuperNintendoWorldChat)
                    .zIndex(1)
            }
        }
        .fullScreenCover(isPresented: $showStartView) {
            StartView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToMessagesTab)) { _ in
            selectedTab = .messages
        }
    }
}







struct ProfileView: View {
    @Binding var showStartView: Bool
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        VStack {
            Text("プロフィール")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Button(action: {
                logout()
            }) {
                Text("ログアウト")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            userProfileManager.reset()
            showStartView = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

