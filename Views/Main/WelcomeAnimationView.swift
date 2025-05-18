//
//  WelcomeAnimationView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2025/01/07.
//

import SwiftUI

struct WelcomeAnimationView: View {
    @Binding var showWelcomeAnimation: Bool
    var onCompletion: () -> Void
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var showSecondText: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // ロゴ
                Image("UNIGATCH02")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // サブテキスト
                if showSecondText {
                    Text("ユニバーサル・スタジオ・ジャパンを\n一緒に楽しむ仲間を見つけよう！")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(1)
                        .padding(.horizontal, 40)
                    
                    Text("ワンアトラクションでマッチング！")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                        .opacity(1)
                        .padding(.top, 10)
                }
            }
        }
        .onAppear {
            // アニメーションシーケンス
            withAnimation(.easeOut(duration: 0.5)) {
                logoScale = 1.0
                logoOpacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showSecondText = true
                }
            }
            
            // メイン画面への遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showWelcomeAnimation = false
                    onCompletion()
                }
            }
        }
    }
}

