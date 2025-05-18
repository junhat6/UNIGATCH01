//
//  Item.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/10.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
