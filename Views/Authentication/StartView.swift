//
//  StartView.swift
//  UNIGATCH01
//
//  Created by 服部潤一 on 2024/12/06.
//

import SwiftUI
import FirebaseAuth

struct StartView: View {
    @State private var showRegister = false
    @State private var showLogin = false
    @State private var isLoading = true
    @State private var currentUser: User?
    @State private var isNewUser = false
    @State private var userProfile: UserProfile?
    @State private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    @State private var showWelcomeAnimation = false
    @State private var showMainView = false
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if isNewUser {
                GenderSelectView()
            } else if showWelcomeAnimation {
                WelcomeAnimationView(showWelcomeAnimation: $showWelcomeAnimation, onCompletion: {
                    showMainView = true
                })
            } else if showMainView {
                MainView()
            } else {
                // 未ログインの場合は通常のStartViewを表示
                VStack {
                    Spacer()
                    
                    // ロゴとテキスト
                    VStack(spacing: 20) {
                        Image("UNIGATCH02")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        
                        Text("ゆにがっち")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                    }
                    
                    Spacer()
                    
                    // ボタン
                    VStack(spacing: 16) {
                        Button(action: {
                            showRegister = true
                        }) {
                            Text("さっそくはじめる")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.95, green: 0.4, blue: 0.4))
                                .cornerRadius(25)
                        }
                        .sheet(isPresented: $showRegister) {
                            RegisterView()
                        }
                        
                        Button(action: {
                            showLogin = true
                        }) {
                            Text("ログイン")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                        }
                        .sheet(isPresented: $showLogin) {
                            LoginView()
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // バージョン番号
                    Text("ver. 9.4.3")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .onAppear {
            checkCurrentUser()
        }
        .onDisappear {
            if let handle = authStateDidChangeListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }
    
    private func checkCurrentUser() {
        isLoading = true
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [self] auth, user in
            self.currentUser = user
            if let user = user {
                userProfileManager.loadUserProfile()
                let userProfileService = UserProfileService()
                userProfileService.getUserProfile(userId: user.uid) { result in
                    switch result {
                    case .success(let profile):
                        if profile.nickname.isEmpty || profile.gender.isEmpty {
                            self.isNewUser = true
                        } else {
                            self.userProfile = profile
                            self.showWelcomeAnimation = true
                        }
                    case .failure(_):
                        self.isNewUser = true
                    }
                    self.isLoading = false
                }
            } else {
                userProfileManager.reset()
                self.isLoading = false
            }
        }
    }
}






