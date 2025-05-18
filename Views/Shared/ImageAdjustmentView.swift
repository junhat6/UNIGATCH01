//
//  ImageAdjustmentView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/13.
//

import SwiftUI

struct ImageAdjustmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // ナビゲーションヘッダー
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("サイズと位置の調整")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background(Color.white)
            
            // 画像調整エリア
            GeometryReader { geometry in
                ZStack {
                    Color.black
                    
                    // 画像表示エリア
                    ZStack {
                        // 画像を配置
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                        
                        // マスク
                        let size = min(geometry.size.width, geometry.size.height) - 40
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .mask(
                                Rectangle()
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black)
                                            .frame(width: size, height: size)
                                            .blendMode(.destinationOut)
                                    )
                            )
                        
                        // 切り抜き枠の白い枠線
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: size, height: size)
                    }
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / self.lastScale
                                    self.lastScale = value
                                    self.scale = min(max(self.scale * delta, 0.5), 4)
                                }
                                .onEnded { _ in
                                    self.lastScale = 1.0
                                },
                            DragGesture()
                                .onChanged { value in
                                    self.offset = CGSize(
                                        width: self.lastOffset.width + value.translation.width,
                                        height: self.lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    self.lastOffset = self.offset
                                }
                        )
                    )
                }
            }
            
            // 次へボタン
            Button(action: {
                if let adjustedImage = cropToSquare(image: image, scale: scale, offset: offset) {
                    image = adjustedImage
                }
                dismiss()
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
            .padding(.vertical, 20)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func cropToSquare(image: UIImage, scale: CGFloat, offset: CGSize) -> UIImage? {
        let size = min(image.size.width, image.size.height)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { context in
            // 背景を透明に設定
            UIColor.clear.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            
            // クリッピングパスを設定（角丸の適用）
            let bezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: size * 0.2)
            bezierPath.addClip()
            
            // 画像の描画
            context.cgContext.translateBy(x: size/2, y: size/2)
            context.cgContext.scaleBy(x: scale, y: scale)
            context.cgContext.translateBy(x: offset.width, y: offset.height)
            context.cgContext.translateBy(x: -image.size.width/2, y: -image.size.height/2)
            
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
    }
}

