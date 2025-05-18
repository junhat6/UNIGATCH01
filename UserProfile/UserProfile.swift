

import Foundation
import FirebaseFirestore
import Combine

class UserProfile: ObservableObject, Codable, Identifiable {
    @DocumentID var id: String?
    @Published var nickname: String
    @Published var gender: String
    @Published var age: String
    @Published var residence: String
    @Published var occupation: String
    @Published var height: String
    @Published var purpose: String
    @Published var annualPass: String
    @Published var thrillRide: String
    @Published var favoriteAttraction: String
    @Published var favoriteArea: String
    @Published var favoriteCharacter: String
    @Published var imageUrl: String?
    @Published var introduction: String?
    @Published var iconImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case gender
        case age
        case residence
        case occupation
        case height
        case purpose
        case annualPass = "annual_pass"
        case thrillRide = "thrill_ride"
        case favoriteAttraction = "favorite_attraction"
        case favoriteArea = "favorite_area"
        case favoriteCharacter = "favorite_character"
        case imageUrl = "image_url"
        case introduction
        case iconImageUrl = "icon_image_url"
    }

    init(id: String? = nil, nickname: String = "", gender: String = "", age: String = "", residence: String = "", occupation: String = "", height: String = "", purpose: String = "", annualPass: String = "", thrillRide: String = "", favoriteAttraction: String = "", favoriteArea: String = "", favoriteCharacter: String = "", imageUrl: String? = nil, introduction: String? = nil, iconImageUrl: String? = nil) {
        self.id = id
        self.nickname = nickname
        self.gender = gender
        self.age = age
        self.residence = residence
        self.occupation = occupation
        self.height = height
        self.purpose = purpose
        self.annualPass = annualPass
        self.thrillRide = thrillRide
        self.favoriteAttraction = favoriteAttraction
        self.favoriteArea = favoriteArea
        self.favoriteCharacter = favoriteCharacter
        self.imageUrl = imageUrl
        self.introduction = introduction
        self.iconImageUrl = iconImageUrl
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        gender = try container.decode(String.self, forKey: .gender)
        age = try container.decode(String.self, forKey: .age)
        residence = try container.decode(String.self, forKey: .residence)
        occupation = try container.decode(String.self, forKey: .occupation)
        height = try container.decode(String.self, forKey: .height)
        purpose = try container.decode(String.self, forKey: .purpose)
        annualPass = try container.decode(String.self, forKey: .annualPass)
        thrillRide = try container.decode(String.self, forKey: .thrillRide)
        favoriteAttraction = try container.decode(String.self, forKey: .favoriteAttraction)
        favoriteArea = try container.decode(String.self, forKey: .favoriteArea)
        favoriteCharacter = try container.decode(String.self, forKey: .favoriteCharacter)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        introduction = try container.decodeIfPresent(String.self, forKey: .introduction)
        iconImageUrl = try container.decodeIfPresent(String.self, forKey: .iconImageUrl)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(gender, forKey: .gender)
        try container.encode(age, forKey: .age)
        try container.encode(residence, forKey: .residence)
        try container.encode(occupation, forKey: .occupation)
        try container.encode(height, forKey: .height)
        try container.encode(purpose, forKey: .purpose)
        try container.encode(annualPass, forKey: .annualPass)
        try container.encode(thrillRide, forKey: .thrillRide)
        try container.encode(favoriteAttraction, forKey: .favoriteAttraction)
        try container.encode(favoriteArea, forKey: .favoriteArea)
        try container.encode(favoriteCharacter, forKey: .favoriteCharacter)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(introduction, forKey: .introduction)
        try container.encodeIfPresent(iconImageUrl, forKey: .iconImageUrl)
    }
}

