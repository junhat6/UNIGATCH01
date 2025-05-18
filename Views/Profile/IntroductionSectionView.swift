import SwiftUI

struct IntroductionSectionView: View {
    @Binding var introduction: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("自己紹介")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $introduction)
                .frame(height: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}

