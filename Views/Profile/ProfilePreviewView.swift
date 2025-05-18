//
//  ProfilePreviewView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/11.
//

import SwiftUI
import FirebaseStorage
import Foundation

struct ProfilePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userProfile: UserProfile
    @State private var profileImages: [UIImage] = []
    @State private var currentImageIndex = 0
    @State private var showWelcomeAnimation = false
    @State private var showMainView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // プロフィール写真エリア
                    ZStack(alignment: .bottom) {
                        if !profileImages.isEmpty {
                            Image(uiImage: profileImages[currentImageIndex])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 400)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 400)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // 写真インジケーター
                        if profileImages.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<profileImages.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        
                        // 左右タップエリア
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        currentImageIndex = (currentImageIndex - 1 + profileImages.count) % profileImages.count
                                    }
                                }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        currentImageIndex = (currentImageIndex + 1) % profileImages.count
                                    }
                                }
                        }
                    }
                    
                    // プロフィール情報
                    VStack(spacing: 24) {
                        // 基本情報
                        VStack(alignment: .center, spacing: 8) {
                            Text("\(userProfile.nickname) ・ \(userProfile.age)")
                                .font(.system(size: 24, weight: .bold))
                            Text(userProfile.residence)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // プロフィール詳細
                        VStack(spacing: 24) {
                            // 基本情報セクション
                            ProfileSection(title: "基本情報", items: [
                                ProfileItem(icon: "briefcase", title: "職種", value: userProfile.occupation),
                                ProfileItem(icon: "ruler", title: "身長", value: userProfile.height),
                                ProfileItem(icon: "heart", title: "目的", value: userProfile.purpose)
                            ])
                            
                            // USJ情報セクション
                            ProfileSection(title: "USJ情報", items: [
                                ProfileItem(icon: "ticket", title: "年パス", value: userProfile.annualPass),
                                ProfileItem(icon: "bolt", title: "絶叫", value: userProfile.thrillRide),
                                ProfileItem(icon: "star", title: "好きなアトラクション", value: userProfile.favoriteAttraction),
                                ProfileItem(icon: "map", title: "好きなエリア", value: userProfile.favoriteArea)
                            ])
                            
                            if !userProfile.favoriteCharacter.isEmpty {
                                ProfileSection(title: "その他", items: [
                                    ProfileItem(icon: "heart.circle", title: "推しキャラ", value: userProfile.favoriteCharacter)
                                ])
                            }
                        }
                        .padding(.horizontal)
                        
                        // 次へボタン
                        Button(action: {
                            showWelcomeAnimation = true
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
                        .padding(.vertical, 40)
                    }
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .offset(y: -20)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                    Text("戻る")
                        .foregroundColor(.white)
                }
            })
        }
        .onAppear {
            loadProfileImages()
        }
        .fullScreenCover(isPresented: $showWelcomeAnimation) {
            WelcomeAnimationView(showWelcomeAnimation: $showWelcomeAnimation) {
                showMainView = true
            }
        }
        .fullScreenCover(isPresented: $showMainView) {
            MainView()
        }
    }
    
    private func loadProfileImages() {
        guard let imageUrl = userProfile.imageUrl else {
            print("No image URL available")
            return
        }
        
        let storage = Storage.storage().reference(forURL: imageUrl)
        
        storage.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImages = [image]
                }
            }
        }
    }
}

// プロフィールセクション
struct ProfileSection: View {
    let title: String
    let items: [ProfileItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    ProfileItemView(item: item)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// プロフィール項目
struct ProfileItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
}

// プロフィール項目ビュー
struct ProfileItemView: View {
    let item: ProfileItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(item.value)
                    .font(.system(size: 16))
            }
            
            Spacer()
        }
    }
}

// 角丸の一部だけを適用するための拡張
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}




