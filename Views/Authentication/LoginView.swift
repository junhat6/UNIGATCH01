//
//  LoginView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/10.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showMainView = false
    
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
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            // メインコンテンツ
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("ログイン")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                    
                    Text("メールアドレスとパスワードを入力してログインしてください。")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 20) {
                        // メールアドレス入力フィールド
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("メールアドレス", text: $email)
                                .font(.system(size: 16))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.systemGray4))
                        }
                        
                        // パスワード入力フィールド
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if showPassword {
                                    TextField("パスワード", text: $password)
                                } else {
                                    SecureField("パスワード", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.system(size: 16))
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    .padding(.top, 20)
                    
                    // パスワードを忘れた場合のリンク
                    Button(action: {
                        // パスワードリセット処理
                    }) {
                        Text("パスワードをお忘れの方はこちら")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .underline()
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // ログインボタン
            Button(action: {
                login()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("ログイン")
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red)
            .cornerRadius(25)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showMainView) {
            // メイン画面へ遷移
            Text("メイン画面")
        }
    }
    
    private func login() {
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
                return
            }
            
            // ログイン成功、メイン画面へ遷移
            showMainView = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

