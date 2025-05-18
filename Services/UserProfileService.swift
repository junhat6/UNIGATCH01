//
//  UserProfileService.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/11.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class UserProfileService {
    private let db = Firestore.firestore()
    
    func saveUserProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"])))
            return
        }
        
        if profile.nickname.isEmpty {
            profile.nickname = "ゲスト\(String(userId.prefix(4)))"
        }
        
        do {
            var profileData = try Firestore.Encoder().encode(profile)
            profileData["id"] = userId
            profileData["image_url"] = profile.imageUrl
            profileData["icon_image_url"] = profile.iconImageUrl
            
            db.collection("user_profiles").document(userId).setData(profileData, merge: true) { error in
                if let error = error {
                    print("ユーザープロフィール保存エラー: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("ユーザープロフィールが正常に保存されました。Image URL: \(profile.imageUrl ?? "Not set"), Icon URL: \(profile.iconImageUrl ?? "Not set")")
                    completion(.success(()))
                }
            }
        } catch {
            print("ユーザープロフィールエンコードエラー: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func getUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("user_profiles").document(userId).getDocument { [weak self] (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                completion(.failure(NSError(domain: "UserProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                return
            }
            
            let profile = UserProfile(
                id: userId,
                nickname: data["nickname"] as? String ?? "Unknown",
                gender: data["gender"] as? String ?? "",
                age: data["age"] as? String ?? "",
                residence: data["residence"] as? String ?? "",
                occupation: data["occupation"] as? String ?? "",
                height: data["height"] as? String ?? "",
                purpose: data["purpose"] as? String ?? "",
                annualPass: data["annual_pass"] as? String ?? "",
                thrillRide: data["thrill_ride"] as? String ?? "",
                favoriteAttraction: data["favorite_attraction"] as? String ?? "",
                favoriteArea: data["favorite_area"] as? String ?? "",
                favoriteCharacter: data["favorite_character"] as? String ?? "",
                imageUrl: data["image_url"] as? String,
                introduction: data["introduction"] as? String,
                iconImageUrl: data["icon_image_url"] as? String
            )
            
            completion(.success(profile))
        }
    }
    // 新しいメソッド: ユーザープロフィールの存在確認
    func checkUserProfileExists(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "UserProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"]))
            return
        }
        
        db.collection("user_profiles").document(userId).getDocument { (document, error) in
            if let error = error {
                print("プロフィール確認エラー: \(error.localizedDescription)")
                completion(false, error)
            } else {
                completion(document?.exists ?? false, nil)
            }
        }
    }
}


