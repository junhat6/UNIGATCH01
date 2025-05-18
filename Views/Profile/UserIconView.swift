//
//  UserIconView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/17.
//

import SwiftUI

struct UserIconView: View {
    let imageUrl: String?
    let size: CGFloat
    
    init(imageUrl: String?, size: CGFloat = 40) {
        self.imageUrl = imageUrl
        self.size = size
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            @unknown default:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}



