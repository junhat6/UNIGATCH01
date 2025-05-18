import SwiftUI

class PickerStates: ObservableObject {
    @Published var showNicknamePicker = false
    @Published var showGenderPicker = false
    @Published var showAgePicker = false
    @Published var showResidencePicker = false
    @Published var showOccupationPicker = false
    @Published var showHeightPicker = false
    @Published var showPurposePicker = false
    @Published var showAnnualPassPicker = false
    @Published var showThrillRidePicker = false
    @Published var showFavoriteAttractionPicker = false
    @Published var showFavoriteAreaPicker = false
    @Published var showFavoriteCharacterAlert = false
}

extension View {
    func attachPickerSheets(pickerStates: ObservedObject<PickerStates>, userProfile: Binding<UserProfile>) -> some View {
        self
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showNicknamePicker }, set: { pickerStates.wrappedValue.showNicknamePicker = $0 })) {
                Text("Nickname Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showGenderPicker }, set: { pickerStates.wrappedValue.showGenderPicker = $0 })) {
                Text("Gender Picker") // Placeholder

            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showAgePicker }, set: { pickerStates.wrappedValue.showAgePicker = $0 })) {
                Text("Age Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showResidencePicker }, set: { pickerStates.wrappedValue.showResidencePicker = $0 })) {
                Text("Residence Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showOccupationPicker }, set: { pickerStates.wrappedValue.showOccupationPicker = $0 })) {
                Text("Occupation Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showHeightPicker }, set: { pickerStates.wrappedValue.showHeightPicker = $0 })) {
                Text("Height Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showPurposePicker }, set: { pickerStates.wrappedValue.showPurposePicker = $0 })) {
                Text("Purpose Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showAnnualPassPicker }, set: { pickerStates.wrappedValue.showAnnualPassPicker = $0 })) {
                Text("Annual Pass Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showThrillRidePicker }, set: { pickerStates.wrappedValue.showThrillRidePicker = $0 })) {
                Text("Thrill Ride Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showFavoriteAttractionPicker }, set: { pickerStates.wrappedValue.showFavoriteAttractionPicker = $0 })) {
                Text("Favorite Attraction Picker") // Placeholder
            }
            .sheet(isPresented: Binding(get: { pickerStates.wrappedValue.showFavoriteAreaPicker }, set: { pickerStates.wrappedValue.showFavoriteAreaPicker = $0 })) {
                Text("Favorite Area Picker") // Placeholder
            }
            .alert("推しキャラ", isPresented: Binding(get: { pickerStates.wrappedValue.showFavoriteCharacterAlert }, set: { pickerStates.wrappedValue.showFavoriteCharacterAlert = $0 })) {
                TextField("推しキャラを入力", text: userProfile.favoriteCharacter)
                Button("OK", action: {})
                Button("キャンセル", role: .cancel, action: {})
            } message: {
                Text("推しキャラを入力してください")
            }
    }
}



