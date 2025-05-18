import SwiftUI

struct ProfileSectionView: View {
    @Binding var userProfile: UserProfile
    @ObservedObject var pickerStates: PickerStates
    
    var body: some View {
        VStack(spacing: 0) {
            Text("プロフィール")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            VStack(spacing: 0) {
                ProfileField(
                    icon: "person.fill",
                    title: "ニックネーム",
                    value: userProfile.nickname,
                    action: { pickerStates.showNicknamePicker = true }
                )
                
                ProfileField(
                    icon: "person.2.fill",
                    title: "性別",
                    value: userProfile.gender,
                    action: { pickerStates.showGenderPicker = true }
                )
                
                ProfileField(
                    icon: "calendar",
                    title: "年齢",
                    value: userProfile.age,
                    action: { pickerStates.showAgePicker = true }
                )
                
                ProfileField(
                    icon: "mappin.circle.fill",
                    title: "在住地",
                    value: userProfile.residence,
                    action: { pickerStates.showResidencePicker = true }
                )
                
                ProfileField(
                    icon: "briefcase.fill",
                    title: "職種",
                    value: userProfile.occupation,
                    action: { pickerStates.showOccupationPicker = true }
                )
                
                ProfileField(
                    icon: "ruler.fill",
                    title: "身長",
                    value: userProfile.height,
                    action: { pickerStates.showHeightPicker = true }
                )
                
                ProfileField(
                    icon: "heart.fill",
                    title: "このアプリを使用する目的",
                    value: userProfile.purpose,
                    action: { pickerStates.showPurposePicker = true }
                )
                
                ProfileField(
                    icon: "ticket.fill",
                    title: "年パス",
                    value: userProfile.annualPass,
                    action: { pickerStates.showAnnualPassPicker = true }
                )
                
                ProfileField(
                    icon: "bolt.fill",
                    title: "絶叫",
                    value: userProfile.thrillRide,
                    action: { pickerStates.showThrillRidePicker = true }
                )
                
                ProfileField(
                    icon: "star.fill",
                    title: "好きなアトラクション",
                    value: userProfile.favoriteAttraction,
                    action: { pickerStates.showFavoriteAttractionPicker = true }
                )
                
                ProfileField(
                    icon: "map.fill",
                    title: "好きなエリア",
                    value: userProfile.favoriteArea,
                    action: { pickerStates.showFavoriteAreaPicker = true }
                )
                
                ProfileField(
                    icon: "heart.circle.fill",
                    title: "推しキャラ",
                    value: userProfile.favoriteCharacter,
                    action: { pickerStates.showFavoriteCharacterAlert = true }
                )
            }
            .background(Color.white)
        }
        .attachPickerSheets(pickerStates: _pickerStates, userProfile: $userProfile)
    }
}

struct ProfileField: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value.isEmpty ? "未設定" : value)
                    .foregroundColor(value.isEmpty ? .gray : .blue)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        Divider()
    }
}

#Preview {
    ProfileSectionView(userProfile: .constant(UserProfile()), pickerStates: PickerStates())
}


