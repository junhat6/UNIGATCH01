//
//  SharedComponents.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/13.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    if title == "推しキャラ" {
                        TextField("（例）マリオ", text: .constant(value))
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(value)
                            .font(.system(size: 16))
                            .foregroundColor(value.isEmpty ? .gray : .red)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16) // 左右のパディングを追加
                .padding(.vertical, 12)
                
                Divider()
            }
        }
    }
}

struct PickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String
    let items: [String]
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Button("キャンセル") {
                    dismiss()
                }
                .foregroundColor(.black)
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Button("OK") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // ピッカー
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Button(action: {
                            selection = item
                            dismiss()
                        }) {
                            HStack {
                                Text(item)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                if selection == item {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(selection == item ? Color(.systemGray6) : .white)
                        }
                        Divider()
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct TextInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Button("キャンセル") {
                    dismiss()
                }
                .foregroundColor(.black)
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                Button("OK") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // テキスト入力
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .background(Color.white)
    }
}

