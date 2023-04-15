//
//  LevelCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct LevelCinematic: Codable {
    init(name: String,
                triggerCoordinate: String,
                category: Category,
                isAvailable: Bool = true) {
        self.name = name
        self.triggerCoordinate = triggerCoordinate
        self.category = category
        self.isAvailable = isAvailable
    }
    
    let name: String
    let triggerCoordinate: String?
    let category: Category
    var isAvailable: Bool = true
    
    enum Category: String, Codable {
        case onStart
        case onConversation
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case triggerCoordinate
        case category
    }
}
