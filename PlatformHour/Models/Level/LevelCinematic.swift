//
//  LevelCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct LevelCinematic: Codable {
    let name: String
    let triggerCoordinate: String?
    let category: Category
    
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
