//
//  LevelConversation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct LevelConversation: Codable {
    let name: String
    let triggerCoordinate: String?
    let category: Category
    
    enum Category: String, Codable {
        case onStart
        case onCinematic
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case triggerCoordinate
        case category
    }
}
