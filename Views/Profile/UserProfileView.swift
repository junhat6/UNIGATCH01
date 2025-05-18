//
//  UserProfileView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/21.
//

import SwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    let userId: String
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // プロフィール写真
                if let imageUrl = viewModel.userProfile?.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                
                // ユーザー情報
                if let profile = viewModel.userProfile {
                    Text(profile.nickname)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(profile.age) ・ \(profile.gender) ・ \(profile.residence)")
                        .foregroundColor(.secondary)
                    
                    // その他のプロフィール情報
                    Group {
                        ProfileInfoRow(title: "職種", value: profile.occupation)
                        ProfileInfoRow(title: "身長", value: profile.height)
                        ProfileInfoRow(title: "目的", value: profile.purpose)
                        ProfileInfoRow(title: "年パス", value: profile.annualPass)
                        ProfileInfoRow(title: "絶叫", value: profile.thrillRide)
                        ProfileInfoRow(title: "好きなアトラクション", value: profile.favoriteAttraction)
                        ProfileInfoRow(title: "好きなエリア", value: profile.favoriteArea)
                        if !profile.favoriteCharacter.isEmpty {
                            ProfileInfoRow(title: "推しキャラ", value: profile.favoriteCharacter)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("プロフィール", displayMode: .inline)
        .navigationBarItems(leading: Button("閉じる") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            viewModel.loadUserProfile(userId: userId)
        }
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    private let userProfileService = UserProfileService()
    
    func loadUserProfile(userId: String) {
        userProfileService.getUserProfile(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                case .failure(let error):
                    print("Error loading user profile: \(error.localizedDescription)")
                }
            }
        }
    }
}




