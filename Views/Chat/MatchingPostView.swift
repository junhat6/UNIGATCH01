//
//  MatchingPostView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import SwiftUI

struct MatchingPost {
    var title: String
    var content: String
    var hostGroupSize: Int
    var hostGroupMale: Int
    var hostGroupFemale: Int
    var desiredGroupSize: Int
    var meetupLocation: String
    var selectedAttractions: Set<String>
    var closingTime: Date // New field for closing time
}

struct MatchingPostView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var hostGroupMale: Int = 0
    @State private var hostGroupFemale: Int = 0
    @State private var desiredGroupSize: Int = 1
    @State private var meetupLocation: String = ""
    @State private var selectedAttractions: Set<String> = []
    @State private var showAttractionPicker = false
    @State private var selectedHours: Int = 1
    @State private var selectedMinutes: Int = 0
    @State private var showTimePicker = false
    var onPost: (MatchingPost) -> Void
    
    private let attractions = ["未選択", "会ってから話し合いたい", "ハリウッド・ドリーム・ザ・ライド", "ザ・フライング・ダイナソー", "ハリー・ポッター・アンド・ザ・フォービドゥン・ジャーニー™", "スペース・ファンタジー・ザ・ライド", "アメージング・アドベンチャー・オブ・スパイダーマン・ザ・ライド 4K3D", "ジョーズ®", "シング・オン・ツアー", "ミニオン・ハチャメチャ・ライド", "ヨッシー・アドベンチャー", "マリオカート～クッパの挑戦状～", "名探偵コナン 4-D ライブ・ショー", "フライト・オブ・ザ・ヒッポグリフ™", "ハリウッド・ドリーム・ザ・ライド 〜バックドロップ〜", "ジュラシック・パーク・ザ・ライド", "鬼滅の刃 XRライド", "その他"]
    
    private var totalGroupSize: Int {
        hostGroupMale + hostGroupFemale
    }
    
    private var closingTimeString: String {
        if selectedHours == 0 && selectedMinutes == 0 {
            return "設定なし"
        } else {
            var components = [String]()
            if selectedHours > 0 {
                components.append("\(selectedHours)時間")
            }
            if selectedMinutes > 0 {
                components.append("\(selectedMinutes)分")
            }
            return components.joined(separator: " ")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // タイトルカード
                    GroupBox {
                        TextField("例：ジェットコースター好きな人募集！", text: $title)
                            .font(.system(size: 16))
                            .padding(.vertical, 8)
                    } label: {
                        Label("タイトル（任意）", systemImage: "pencil")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 募集内容カード
                    GroupBox {
                        TextEditor(text: $content)
                            .frame(height: 100)
                            .cornerRadius(8)
                    } label: {
                        Label("募集内容", systemImage: "text.bubble")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // グループ情報カード
                    GroupBox {
                        VStack(spacing: 16) {
                            // 現在のグループ構成を視覚化
                            HStack(spacing: 20) {
                                GroupCompositionView(
                                    male: hostGroupMale,
                                    female: hostGroupFemale,
                                    total: totalGroupSize
                                )
                                
                                Divider()
                                
                                VStack(alignment: .leading) {
                                    Text("募集人数")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    HStack {
                                        Image(systemName: "person.2")
                                        Text("\(desiredGroupSize)人")
                                    }
                                    .font(.title3)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            // 人数設定
                            VStack(spacing: 12) {
                                NumberPickerRow(title: "男性の人数", value: $hostGroupMale, range: 0...10)
                                NumberPickerRow(title: "女性の人数", value: $hostGroupFemale, range: 0...10)
                                NumberPickerRow(title: "募集人数", value: $desiredGroupSize, range: 1...10)
                            }
                        }
                    } label: {
                        Label("グループ情報", systemImage: "person.2")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 場所とアトラクションカード
                    GroupBox {
                        VStack(spacing: 16) {
                            // 合流場所
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.red)
                                    Text("合流予定の場所")
                                        .font(.subheadline)
                                }
                                TextField("例：マリオカート", text: $meetupLocation)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Divider()
                            
                            // アトラクション選択
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("行きたいアトラクション")
                                        .font(.subheadline)
                                }
                                
                                Button(action: {
                                    showAttractionPicker = true
                                }) {
                                    HStack {
                                        if selectedAttractions.isEmpty {
                                            Text("選択してください")
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("\(selectedAttractions.count)個選択中")
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    } label: {
                        Label("場所・アトラクション", systemImage: "map")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 締め切り時間カード
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.orange)
                                    Text("締め切り時間")
                                        .font(.subheadline)
                                }
                                Text(closingTimeString)
                                    .font(.headline)
                            }
                            Spacer()
                            Button(action: {
                                showTimePicker = true
                            }) {
                                Text("変更")
                                    .foregroundColor(.blue)
                            }
                        }
                    } label: {
                        Label("締め切り設定", systemImage: "timer")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .navigationBarTitle("マッチング募集", displayMode: .inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    isPresented = false
                },
                trailing: Button("投稿") {
                    let closingTime = Calendar.current.date(byAdding: .minute, value: selectedHours * 60 + selectedMinutes, to: Date()) ?? Date()
                    let post = MatchingPost(
                        title: title,
                        content: content,
                        hostGroupSize: totalGroupSize,
                        hostGroupMale: hostGroupMale,
                        hostGroupFemale: hostGroupFemale,
                        desiredGroupSize: desiredGroupSize,
                        meetupLocation: meetupLocation,
                        selectedAttractions: selectedAttractions,
                        closingTime: closingTime
                    )
                    onPost(post)
                    isPresented = false
                }
            )
            .sheet(isPresented: $showAttractionPicker) {
                AttractionPickerView(attractions: attractions, selectedAttractions: $selectedAttractions)
            }
            .sheet(isPresented: $showTimePicker) {
                VStack {
                    TimePickerView(selectedHours: $selectedHours, selectedMinutes: $selectedMinutes)
                    Button("完了") {
                        showTimePicker = false
                    }
                    .padding()
                }
            }
        }
    }
}

struct GroupCompositionView: View {
    let male: Int
    let female: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在のグループ")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                // 男性
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text("\(male)")
                        .font(.headline)
                }
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // 女性
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.pink)
                    Text("\(female)")
                        .font(.headline)
                }
                .frame(width: 44, height: 44)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(8)
                
                // 合計
                VStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.gray)
                    Text("\(total)")
                        .font(.headline)
                }
                .frame(width: 44, height: 44)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct NumberPickerRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 0) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                Text("\(value)")
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct TimePickerView: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    
    let hours = Array(0...24)
    let minutes = Array(0..<60)
    
    var body: some View {
        VStack {
            Picker("時間", selection: $selectedHours) {
                ForEach(hours, id: \.self) { hour in
                    Text("\(hour)時間").tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Picker("分", selection: $selectedMinutes) {
                ForEach(minutes, id: \.self) { minute in
                    Text("\(minute)分").tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}





struct AttractionPickerView: View {
    let attractions: [String]
    @Binding var selectedAttractions: Set<String>
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(attractions, id: \.self) { attraction in
                    Button(action: {
                        if attraction == "未選択" || attraction == "会ってから話し合いたい" {
                            selectedAttractions = [attraction]
                        } else {
                            if selectedAttractions.contains("未選択") || selectedAttractions.contains("会ってから話し合いたい") {
                                selectedAttractions.removeAll()
                            }
                            if selectedAttractions.contains(attraction) {
                                selectedAttractions.remove(attraction)
                            } else {
                                selectedAttractions.insert(attraction)
                            }
                        }
                    }) {
                        HStack {
                            Text(attraction)
                            Spacer()
                            if selectedAttractions.contains(attraction) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("アトラクションを選択", displayMode: .inline)
            .navigationBarItems(trailing: Button("完了") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


