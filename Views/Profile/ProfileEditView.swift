//
//  ProfileEditView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/12.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userProfile: UserProfile
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var introduction: String = ""
    @State private var showImageAdjustment = false
    @State private var imageToAdjust: UIImage?
    @State private var isLoading = false
    @State private var showNextView = false

    // Picker states
    @StateObject private var pickerStates = PickerStates()
    
    private let maxPhotos = 9
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PhotoSectionView(
                        selectedImages: $selectedImages,
                        showImagePicker: $showImagePicker,
                        maxPhotos: maxPhotos
                    )
                    
                    IntroductionSectionView(introduction: $introduction)
                    
                    ProfileSectionView(
                        userProfile: $userProfile,
                        pickerStates: pickerStates
                    )
                    
                    // 次へボタン
                    Button(action: {
                        showNextView = true
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
                
            }
            .background(Color.white)
            .navigationBarItems(
                leading: ProfileBackButton(action: { dismiss() }),
                trailing: SkipButton(action: { showNextView = true })
            )
            .navigationBarTitle("プロフィール編集", displayMode: .inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $selectedImages, maxSelection: maxPhotos - selectedImages.count)
                    .onDisappear {
                        handleImagePickerDisappear()
                    }
            }
            .fullScreenCover(isPresented: $showNextView) {
                ProfilePreviewView(userProfile: $userProfile)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .attachPickerSheets(pickerStates: ObservedObject(wrappedValue: pickerStates), userProfile: $userProfile)
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
                introduction = userProfile.introduction ?? ""
            }
        }
    }
    
    private func handleImagePickerDisappear() {
        if let lastImage = selectedImages.last {
            let tempImage = lastImage
            selectedImages.removeLast()
            showImageAdjustment = true
            imageToAdjust = tempImage
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
}

// MARK: - Navigation Buttons
struct ProfileBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .foregroundColor(.black)
        }
    }
}

struct SkipButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("スキップ")
                .foregroundColor(.gray)
        }
    }
}


