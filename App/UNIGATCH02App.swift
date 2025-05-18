//
//  UNIGATCH02App.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/10.
//
import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import Foundation
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // FCMの設定
        Messaging.messaging().delegate = self
        
        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        if let token = fcmToken {
            sendTokenToServer(token)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print("Received notification in foreground: \(userInfo)")
        
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("Received notification response: \(userInfo)")
        
        handleNotificationTap(userInfo)
        
        completionHandler()
    }
}

func sendTokenToServer(_ token: String) {
    // ここでトークンをサーバーに送信する処理を実装
    // 例: Firestoreにトークンを保存
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let db = Firestore.firestore()
    db.collection("users").document(userId).setData(["fcmToken": token], merge: true) { error in
        if let error = error {
            print("Error saving FCM token: \(error)")
        } else {
            print("FCM token saved successfully")
        }
    }
}

func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
    // 通知タップ時の処理を実装
    // 例: 特定のチャットルームを開く
    if let roomId = userInfo["roomId"] as? String {
        // チャットルームを開く処理
        print("Opening chat room: \(roomId)")
        // ここで適切なビューを表示するロジックを追加
    }
}


class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile?
    private let userProfileService = UserProfileService()
    private let db = Firestore.firestore()

    init() {
        loadUserProfile()
    }

    func loadUserProfile(completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            completion?(.failure(NSError(domain: "UserProfileManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }

        fetchUserProfile(userId: userId) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.userProfile = profile
                    print("User profile loaded successfully. ID: \(profile.id ?? "nil")")
                    completion?(.success(()))
                }
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }

    func saveUserProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "UserProfileManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }

        do {
            var profileData = try Firestore.Encoder().encode(profile)
            profileData["id"] = userId

            db.collection("user_profiles").document(userId).setData(profileData, merge: true) { error in
                if let error = error {
                    print("Error saving user profile: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.userProfile = profile
                        print("User profile saved successfully")
                        completion(.success(()))
                    }
                }
            }
        } catch {
            print("Error encoding user profile: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    func updateUserIconUrl(_ url: String) {
        userProfile?.iconImageUrl = url
        if let updatedProfile = userProfile {
            saveUserProfile(updatedProfile) { result in
                switch result {
                case .success:
                    print("User icon URL updated successfully")
                case .failure(let error):
                    print("Failed to update user icon URL: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("user_profiles").document(userId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
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
            } else {
                print("No user profile found. Creating a new one.")
                let newProfile = UserProfile(id: userId, nickname: "ゲスト\(String(userId.prefix(4)))")
                self.saveUserProfile(newProfile) { result in
                    switch result {
                    case .success:
                        completion(.success(newProfile))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func reset() {
        userProfile = nil
    }

    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}



@main
struct UNIGATCH02App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userProfileManager = UserProfileManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(userProfileManager)
        }
        .modelContainer(sharedModelContainer)
    }
}






