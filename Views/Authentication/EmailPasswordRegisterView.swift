//
//  EmailPasswordRegisterView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/10.
//

import SwiftUI
import FirebaseAuth

struct EmailPasswordRegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var emailEdited = false
    @State private var passwordEdited = false
    @State private var confirmPasswordEdited = false
    @State private var showGenderSelectView = false
    
    private var isValid: Bool {
        return (!email.isEmpty && isValidEmail(email)) &&
               (!password.isEmpty && password.count >= 6) &&
               (!confirmPassword.isEmpty && password == confirmPassword)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
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
                    Text("メールアドレス登録")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                    
                    Text("パスワードは半角英数字6文字以上で入力してください。")
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
                                .onChange(of: email) { oldValue, newValue in
                                    if !newValue.isEmpty {
                                        emailEdited = true
                                    }
                                }
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(emailEdited && (email.isEmpty || !isValidEmail(email)) ? .red : Color(.systemGray4))
                            
                            if emailEdited && email.isEmpty {
                                Text("メールアドレスを入力してください。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            } else if emailEdited && !isValidEmail(email) {
                                Text("有効なメールアドレスを入力してください。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
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
                            .onChange(of: password) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    passwordEdited = true
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(passwordEdited && (password.isEmpty || password.count < 6) ? .red : Color(.systemGray4))
                            
                            if passwordEdited && password.isEmpty {
                                Text("パスワードを入力してください。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            } else if passwordEdited && password.count < 6 {
                                Text("パスワードは6文字以上で入力してください。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // パスワード確認入力フィールド
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if showConfirmPassword {
                                    TextField("パスワード（確認）", text: $confirmPassword)
                                } else {
                                    SecureField("パスワード（確認）", text: $confirmPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.system(size: 16))
                            .onChange(of: confirmPassword) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    confirmPasswordEdited = true
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(confirmPasswordEdited && (confirmPassword.isEmpty || password != confirmPassword) ? .red : Color(.systemGray4))
                            
                            if confirmPasswordEdited && confirmPassword.isEmpty {
                                Text("パスワードを再入力してください。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            } else if confirmPasswordEdited && password != confirmPassword {
                                Text("パスワードが一致しません。")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // 次へボタン
            Button(action: {
                registerUser()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("次へ")
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isValid ? Color.red : Color(.systemGray3))
            .cornerRadius(25)
            .disabled(!isValid || isLoading)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .fullScreenCover(isPresented: $showGenderSelectView) {
            GenderSelectView()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func registerUser() {
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
                return
            }
            
            if let user = result?.user {
                // 新規登録フラグを設定
                UserDefaults.standard.set(true, forKey: "isNewRegistration_\(user.uid)")
                // GenderSelectViewに遷移
                showGenderSelectView = true
            }
        }
    }
}

struct EmailPasswordRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        EmailPasswordRegisterView()
    }
}

