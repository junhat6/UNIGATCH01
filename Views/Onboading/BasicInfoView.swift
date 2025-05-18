//
//  BasicInfoView.swift
//  UNIGATCH01
//
//  Created by 服部潤一 on 2024/12/06.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Foundation

struct BasicInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showHeightPicker = false
    @State private var showResidencePicker = false
    @State private var showPurposePicker = false
    @State private var showAnnualPassPicker = false
    @State private var showOccupationPicker = false
    @State private var showAgePicker = false
    @State private var showThrillRidePicker = false
    @State private var showFavoriteAttractionPicker = false
    @State private var showFavoriteAreaPicker = false
    @State private var showPhotoUploadView = false
    @State private var showFavoriteCharacterAlert = false

    @State private var userProfile = UserProfile(
        nickname: "",
        gender: "",
        age: "",
        residence: "",
        occupation: "",
        height: "",
        purpose: "",
        annualPass: "",
        thrillRide: "",
        favoriteAttraction: "",
        favoriteArea: "",
        favoriteCharacter: ""
    )
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let userProfileService = UserProfileService()
    
    private let heights = ["非公開", "140cm以下"] + (141...199).map { "\($0)cm" } + ["200cm以上"]
    private let residences = ["非公開", "北海道", "青森", "岩手", "宮城", "秋田", "山形", "福島", "茨城", "栃木", "群馬", "埼玉", "千葉", "東京", "神奈川", "新潟", "富山", "石川", "福井", "山梨", "長野", "岐阜", "静岡", "愛知", "三重", "滋賀", "京都", "大阪", "兵庫", "奈良", "和歌山", "鳥取", "島根", "岡山", "広島", "山口", "徳島", "香川", "愛媛", "高知", "福岡", "佐賀", "長崎", "熊本", "大分", "宮崎", "鹿児島", "沖縄"]
    private let purposes = ["友達作り", "恋人作り", "暇つぶし", "ユニバを楽しみたい"]
    private let annualPasses = ["年間パスグランロイヤル", "年間パススタンダード","無"]
    private let occupations = ["非公開", "経営者・役員", "会社員", "パート・アルバイト", "公務員", "教務員", "医療関係者", "自営業・自由業", "専業主婦・主夫", "大学生・大学院生", "専門学生・短大生", "無職", "定年退職", "その他"]
    private let ages = (12...100).map { "\($0)歳" }
    private let thrillRides = ["めっちゃ好き","乗れるっちゃ乗れる", "相手に合わせる", "無理"]
    private let favoriteAttractions = ["ハリウッド・ドリーム・ザ・ライド", "ザ・フライング・ダイナソー", "ハリー・ポッター・アンド・ザ・フォービドゥン・ジャーニー™", "スペース・ファンタジー・ザ・ライド", "アメージング・アドベンチャー・オブ・スパイダーマン・ザ・ライド 4K3D", "ジョーズ®", "シング・オン・ツアー", "ミニオン・ハチャメチャ・ライド", "ヨッシー・アドベンチャー", "マリオカート～クッパの挑戦状～", "名探偵コナン 4-D ライブ・ショー", "フライト・オブ・ザ・ヒッポグリフ™", "ハリウッド・ドリーム・ザ・ライド 〜バックドロップ〜", "ジュラシック・パーク・ザ・ライド", "鬼滅の刃 XRライド", "その他"]
    private let favoriteAreas = ["スーパー・ニンテンドー・ワールド", "ウィザーディング・ワールド・オブ・ハリー・ポッター", "ミニオン・パーク", "ユニバーサル・ワンダーランド", "ハリウッド・エリア", "ニューヨーク・エリア", "サンフランシスコ・エリア", "ジュラシック・パーク", "アミティ・ビレッジ", "ウォーターワールド"]
    
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
                    Text("基本情報")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                    
                    Text("あなたの基本情報を教えてください。")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                    
                    // 情報入力フィールド
                    Group {
                        InfoRow(title: "年齢", value: userProfile.age) {
                            showAgePicker = true
                        }
                        InfoRow(title: "在住地", value: userProfile.residence) {
                            showResidencePicker = true
                        }
                        InfoRow(title: "職種", value: userProfile.occupation) {
                            showOccupationPicker = true
                        }
                        InfoRow(title: "身長", value: userProfile.height) {
                            showHeightPicker = true
                        }
                        InfoRow(title: "このアプリを使用する目的", value: userProfile.purpose) {
                            showPurposePicker = true
                        }
                        InfoRow(title: "年パス", value: userProfile.annualPass) {
                            showAnnualPassPicker = true
                        }
                        InfoRow(title: "絶叫", value: userProfile.thrillRide) {
                            showThrillRidePicker = true
                        }
                        InfoRow(title: "好きなアトラクション", value: userProfile.favoriteAttraction) {
                            showFavoriteAttractionPicker = true
                        }
                        InfoRow(title: "好きなエリア", value: userProfile.favoriteArea) {
                            showFavoriteAreaPicker = true
                        }
                        InfoRow(title: "推しキャラ", value: userProfile.favoriteCharacter.isEmpty ? "未登録" : userProfile.favoriteCharacter) {
                            showFavoriteCharacterAlert = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // 次へボタン
            Button(action: {
                saveUserProfile()
            }) {
                Text("次へ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showHeightPicker) {
            PickerView(selection: $userProfile.height, items: heights, title: "身長")
        }
        .sheet(isPresented: $showResidencePicker) {
            PickerView(selection: $userProfile.residence, items: residences, title: "在住地")
        }
        .sheet(isPresented: $showPurposePicker) {
            PickerView(selection: $userProfile.purpose, items: purposes, title: "このアプリを使用する目的")
        }
        .sheet(isPresented: $showAnnualPassPicker) {
            PickerView(selection: $userProfile.annualPass, items: annualPasses, title: "年パス")
        }
        .sheet(isPresented: $showOccupationPicker) {
            PickerView(selection: $userProfile.occupation, items: occupations, title: "職種")
        }
        .sheet(isPresented: $showAgePicker) {
            PickerView(selection: $userProfile.age, items: ages, title: "年齢")
        }
        .sheet(isPresented: $showThrillRidePicker) {
            PickerView(selection: $userProfile.thrillRide, items: thrillRides, title: "絶叫")
        }
        .sheet(isPresented: $showFavoriteAttractionPicker) {
            PickerView(selection: $userProfile.favoriteAttraction, items: favoriteAttractions, title: "好きなアトラクション")
        }
        .sheet(isPresented: $showFavoriteAreaPicker) {
            PickerView(selection: $userProfile.favoriteArea, items: favoriteAreas, title: "好きなエリア")
        }
        .fullScreenCover(isPresented: $showPhotoUploadView) {
            PhotoUploadView(userProfile: $userProfile)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert("推しキャラ", isPresented: $showFavoriteCharacterAlert) {
            TextField("推しキャラを入力", text: $userProfile.favoriteCharacter)
            Button("OK", action: {})
            Button("キャンセル", role: .cancel, action: {})
        } message: {
            Text("推しキャラを入力してください")
        }
        .onAppear {
            userProfile.gender = UserDefaults.standard.string(forKey: "selectedGender") ?? ""
            userProfile.nickname = UserDefaults.standard.string(forKey: "selectedNickname") ?? ""
        }
    }
    
    private func saveUserProfile() {
        userProfileService.saveUserProfile(userProfile) { result in
            switch result {
            case .success:
                showPhotoUploadView = true
            case .failure(let error):
                showAlert(message: "プロフィールの保存に失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct BasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfoView()
    }
}

