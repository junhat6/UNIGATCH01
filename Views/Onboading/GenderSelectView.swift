//
//  GenderSelectView.swift
//  UNIGATCH01
//
//  Created by 服部潤一 on 2024/12/06.
//

import SwiftUI

struct GenderSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGender: Gender?
    @State private var showNickname = false
    
    enum Gender: String {
        case male = "男性"
        case female = "女性"
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
                Text("性別")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                
                Text("一度登録した性別は変更できません。")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                VStack(spacing: 16) {
                    // 男性ボタン
                    Button(action: {
                        selectedGender = .male
                    }) {
                        HStack {
                            if selectedGender == .male {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Text("男性")
                                .font(.system(size: 16))
                            Spacer()
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .background(selectedGender == .male ? Color(red: 1.0, green: 0.9, blue: 0.9) : Color(.systemGray6))
                        .cornerRadius(25)
                    }
                    .foregroundColor(selectedGender == .male ? .red : .gray)
                    
                    // 女性ボタン
                    Button(action: {
                        selectedGender = .female
                    }) {
                        HStack {
                            if selectedGender == .female {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Text("女性")
                                .font(.system(size: 16))
                            Spacer()
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .background(selectedGender == .female ? Color(red: 1.0, green: 0.9, blue: 0.9) : Color(.systemGray6))
                        .cornerRadius(25)
                    }
                    .foregroundColor(selectedGender == .female ? .red : .gray)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 次へボタン
            Button(action: {
                if let gender = selectedGender {
                    UserDefaults.standard.set(gender.rawValue, forKey: "selectedGender")
                }
                showNickname = true
            }) {
                Text("次へ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedGender != nil ? Color.red : Color(.systemGray3))
                    .cornerRadius(25)
            }
            .fullScreenCover(isPresented: $showNickname) {
                NicknameView()
            }
            .disabled(selectedGender == nil)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
}

struct GenderSelectView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSelectView()
    }
}

