//
//  PhotoUploadView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/10.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import Foundation

struct PhotoUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userProfile: UserProfile
    @State private var selectedImages: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showProfilePreview = false
    @State private var showProfileEditView = false
    @State private var showImageAdjustment = false
    @State private var imageToAdjust: UIImage?

    private let storage = Storage.storage().reference()
    private let userProfileService = UserProfileService()
    
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
            VStack(spacing: 40) {
                Text("写真を登録しましょう")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                
                // プロフィール写真エリア
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 200, height: 200)
                    
                    if let selectedImage = selectedImages.first {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                    
                    // プラスボタン
                    Circle()
                        .fill(Color.red)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        )
                        .offset(x: 70, y: 70)
                }
                .onTapGesture {
                    isImagePickerPresented = true
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    // アップロードボタン
                    Button(action: {
                        if selectedImages.isEmpty == false {
                            uploadImage()
                        } else {
                            isImagePickerPresented = true
                        }
                    }) {
                        if isUploading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(selectedImages.isEmpty ? "写真をアップロード" : "この写真で登録する")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(25)
                    .disabled(isUploading)
                    .padding(.horizontal, 40)
                    
                    Text("※写真はあとで変更できます")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .overlay(
            Group {
                if isUploading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text("アップロード中...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
        )
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(images: $selectedImages, maxSelection: 1)
                .onDisappear {
                    if let lastImage = selectedImages.last {
                        let tempImage = lastImage
                        selectedImages.removeLast()
                        showImageAdjustment = true
                        imageToAdjust = tempImage
                    }
                }
        }
        .fullScreenCover(isPresented: $showProfilePreview) {
            ProfilePreviewView(userProfile: $userProfile)
        }
        .fullScreenCover(isPresented: $showProfileEditView) {
            ProfileEditView(userProfile: $userProfile)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showImageAdjustment) {
            if let image = imageToAdjust {
                ImageAdjustmentView(image: Binding(
                    get: { image },
                    set: { newImage in
                        selectedImages.append(newImage)
                        imageToAdjust = nil
                    }
                ))
            }
        }
        .onAppear {
            loadExistingImages()
        }
    }
    
    private func loadExistingImages() {
        if let imageUrl = userProfile.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        selectedImages = [image]
                    }
                }
            }.resume()
        }
    }
    
    private func uploadImage() {
        guard let image = selectedImages.first,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            showAlert(message: "画像の処理に失敗しました")
            return
        }
        
        isUploading = true
        
        let imageName = UUID().uuidString
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "ユーザー認証に失敗しました")
            isUploading = false
            return
        }
        let imageRef = storage.child("profile_images/\(userId)/\(imageName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            self.isUploading = false
            
            if let error = error {
                print("Image upload error: \(error.localizedDescription)")
                self.showAlert(message: "画像のアップロードに失敗しました: \(error.localizedDescription)")
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL error: \(error.localizedDescription)")
                    self.showAlert(message: "画像URLの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                if let url = url {
                    print("Image uploaded successfully. URL: \(url.absoluteString)")
                    self.updateUserProfile(with: url.absoluteString)
                } else {
                    self.showAlert(message: "画像URLの取得に失敗しました")
                }
            }
        }
    }
    
    private func updateUserProfile(with imageUrl: String) {
        userProfile.imageUrl = imageUrl
        userProfile.iconImageUrl = imageUrl
        userProfileService.saveUserProfile(userProfile) { result in
            switch result {
            case .success:
                print("Profile updated successfully with image URL: \(imageUrl)")
                DispatchQueue.main.async {
                    self.showProfileEditView = true
                    print("Attempting to show ProfileEditView")
                }
            case .failure(let error):
                print("Profile update error: \(error.localizedDescription)")
                self.showAlert(message: "プロフィールの更新に失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}







