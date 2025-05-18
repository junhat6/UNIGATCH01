//
//  FirebaseManager.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/19.
//

import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db: Firestore
    
    private init() {
        // FirebaseApp.configure() の行を削除または以下のようにコメントアウトします
        // FirebaseApp.configure()
        db = Firestore.firestore()
    }
}

