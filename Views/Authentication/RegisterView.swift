//
//  RegisterView.swift
//  UNIGATCH01
//
//  Created by 服部潤一 on 2024/12/06.
//

import SwiftUI

struct RegisterView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailPasswordRegister = false

    var body: some View {
        VStack(spacing: 0) {
            // ナビゲーションヘッダー
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button("ログイン") {
                    // ログインアクション
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            // メインコンテンツ
            ScrollView {
                VStack(spacing: 30) {
                    Text("新規登録")
                        .font(.system(size: 24, weight: .bold))
                    
                    // SNSアイコン
                    Image(systemName: "iphone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                    
                    // 説明テキスト
                    Text("認証を行っても、SNSや外部に利用状況が公開されることはありません。")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                    
                    // ソーシャルログインボタン
                    VStack(spacing: 12) {
                        // LINEボタン
                        Button(action: {
                            // LINE認証（未実装）
                            showAlert = true
                            alertMessage = "LINE認証は現在実装中です。"
                        }) {
                            HStack {
                                Image("line.icon")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                Text("LINEで続ける")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        
                        // Appleボタン
                        Button(action: {
                            // Apple認証（未実装）
                            showAlert = true
                            alertMessage = "Apple認証は現在実装中です。"
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .frame(width: 20, height: 24)
                                Text("Appleで続ける")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        
                        // Googleボタン
                        Button(action: {
                            // Google認証（未実装）
                            showAlert = true
                            alertMessage = "Google認証は現在実装中です。"
                        }) {
                            HStack {
                                Image("google.icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Googleで続ける")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(25)
                        }
                        
                        // その他の登録ボタン
                        Button(action: {
                            showEmailPasswordRegister = true
                        }) {
                            Text("メールアドレスで登録")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.95, green: 0.4, blue: 0.4))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 利用規約とプライバシーポリシー
                    HStack(spacing: 20) {
                        Button("利用規約") {
                            // 利用規約を表示（未実装）
                            showAlert = true
                            alertMessage = "利用規約は現在準備中です。"
                        }
                        Button("プライバシーポリシー") {
                            // プライバシーポリシーを表示（未実装）
                            showAlert = true
                            alertMessage = "プライバシーポリシーは現在準備中です。"
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 20)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("お知らせ"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showEmailPasswordRegister) {
            EmailPasswordRegisterView()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

