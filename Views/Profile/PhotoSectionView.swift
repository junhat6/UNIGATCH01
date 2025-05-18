//
//  PhotoSectionView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/29.
//

import SwiftUI

struct PhotoSectionView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showImagePicker: Bool
    let maxPhotos: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.blue)
                Text("5枚以上登録すると印象アップ！")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)
            
            PhotoGridView(
                selectedImages: selectedImages,
                showImagePicker: $showImagePicker,
                maxPhotos: maxPhotos
            )
            
            Text("写真を長押しすると並べ替えることができます")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

struct PhotoGridView: View {
    let selectedImages: [UIImage]
    @Binding var showImagePicker: Bool
    let maxPhotos: Int
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 1),
            GridItem(.flexible(), spacing: 1),
            GridItem(.flexible(), spacing: 1)
        ], spacing: 1) {
            ForEach(selectedImages.indices, id: \.self) { index in
                PhotoGridItem(image: selectedImages[index], index: index)
            }
            
            if selectedImages.count < maxPhotos {
                AddPhotoButton(action: { showImagePicker = true })
            }
            
            ForEach(0..<(maxPhotos - selectedImages.count - 1), id: \.self) { _ in
                EmptyGridItem()
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PhotoGridItem: View {
    let image: UIImage
    let index: Int
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct EmptyGridItem: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .aspectRatio(1, contentMode: .fit)
    }
}

struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                Text("追加")
                    .font(.caption)
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray5))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

