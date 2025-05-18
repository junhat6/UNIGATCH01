//
//  ReplyInputView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/08.
//

import SwiftUI

enum ReplyViewTransition {
    case bottomSheet // Current style
    case popup
    case slide
    case fade
}

struct ReplyInputView: View {
    @Binding var isPresented: Bool
    @State private var replyText = ""
    @State private var maleCount: Int = 0
    @State private var femaleCount: Int = 0
    @State private var showParticipantPicker = false
    let originalPost: String
    var onSendReply: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Original post content
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("返信先")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(originalPost)
                            .font(.body)
                    }
                    .padding()
                }
                .frame(maxHeight: 150)
                
                Divider()
                
                // Reply input area
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $replyText)
                            .frame(minHeight: 100)
                            .placeholder(when: replyText.isEmpty) {
                                Text("返信を入力")
                                    .foregroundColor(.gray)
                            }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button(action: {
                            showParticipantPicker = true
                        }) {
                            HStack {
                                Image(systemName: "person.2")
                                Text("参加人数: \(maleCount + femaleCount)")
                            }
                            .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showParticipantPicker) {
                            ParticipantPickerView(maleCount: $maleCount, femaleCount: $femaleCount)
                        }
                        
                        Spacer()
                        
                        Text("\(500 - replyText.count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    if maleCount + femaleCount == 0 {
                        Text("参加人数を選択してください")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Bottom toolbar
                HStack {
                    Button(action: {
                        // Add image action
                    }) {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let replyContent = """
                        \(replyText)
                        
                        参加希望: 男性\(maleCount)人, 女性\(femaleCount)人
                        """
                        onSendReply(replyContent)
                        isPresented = false
                    }) {
                        Text("返信")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(replyText.isEmpty || (maleCount + femaleCount == 0) ? Color.gray : Color.blue)
                            .cornerRadius(20)
                    }
                    .disabled(replyText.isEmpty || (maleCount + femaleCount == 0))
                }
                .padding()
            }
            .navigationBarItems(leading: Button("キャンセル") {
                isPresented = false
            })
            .navigationBarTitle("返信", displayMode: .inline)
        }
    }
}

struct ParticipantPickerView: View {
    @Binding var maleCount: Int
    @Binding var femaleCount: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("参加人数")) {
                    Stepper(value: $maleCount, in: 0...10) {
                        Text("男性: \(maleCount)人")
                    }
                    Stepper(value: $femaleCount, in: 0...10) {
                        Text("女性: \(femaleCount)人")
                    }
                }
                
                Section {
                    Text("合計: \(maleCount + femaleCount)人")
                        .font(.headline)
                }
            }
            .navigationBarItems(trailing: Button("完了") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarTitle("参加人数を選択", displayMode: .inline)
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .topLeading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ReplyInputView_Previews: PreviewProvider {
    static var previews: some View {
        ReplyInputView(isPresented: .constant(true), originalPost: "これはオリジナルの投稿です。マッチング募集の内容がここに表示されます。", onSendReply: { _ in })
    }
}






