//
//  LevelObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct LevelObject: Codable, LevelProtocol {
    let id: Int
    let name: String
    let category: Category
    let coordinate: String
    let itinerary: Int?
    let sizeGrowth: Double?
    
    enum Category: String, Codable {
        case player
        case important
        case npc
        case enemy
        case trap
        case collectible
        case container
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case coordinate
        case itinerary
        case sizeGrowth
    }
}
