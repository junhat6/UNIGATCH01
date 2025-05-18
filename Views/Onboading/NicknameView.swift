//
//  NicknameView.swift
//  UNIGATCH01
//
//  Created by 服部潤一 on 2024/12/06.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct NicknameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nickname = ""
    @State private var isEditing = false
    @State private var showError = false
    @State private var showBasicInfo = false
    
    private var isValid: Bool {
        return nickname.count > 0 && nickname.count <= 8
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
            VStack(alignment: .leading, spacing: 20) {
                Text("ニックネーム")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                
                Text("8文字以内で入力してください。\nニックネームはあとから変更できます。")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("入力してください", text: $nickname)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: nickname) { oldValue, newValue in
                            if newValue.count > 8 {
                                nickname = String(newValue.prefix(8))
                            }
                            showError = !isValid
                        }
                        .onTapGesture {
                            isEditing = true
                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(showError ? .red : Color(.systemGray4))
                    
                    if showError && nickname.count > 8 {
                        Text("8文字以内のニックネームを入力してください。")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 20)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 次へボタン
            Button(action: {
                UserDefaults.standard.set(nickname, forKey: "selectedNickname")
                saveNicknameToFirestore(nickname)
                showBasicInfo = true
            }) {
                Text("次へ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isValid ? Color.red : Color(.systemGray3))
                    .cornerRadius(25)
            }
            .fullScreenCover(isPresented: $showBasicInfo) {
                BasicInfoView()
            }
            .disabled(!isValid)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
    
    private func saveNicknameToFirestore(_ nickname: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("user_profiles").document(userId).setData(["nickname": nickname], merge: true) { error in
            if let error = error {
                print("Error saving nickname: \(error.localizedDescription)")
            } else {
                print("Nickname successfully saved to Firestore")
            }
        }
    }
}

struct NicknameView_Previews: PreviewProvider {
    static var previews: some View {
        NicknameView()
    }
}

