//
//  LevelObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct LevelObject: Codable, LevelProtocol {
    init(id: Int,
                name: String,
                coordinate: String,
                category: Category,
                itinerary: Int,
                sizeGrowth: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.coordinate = coordinate
        self.itinerary = itinerary
    }
    
    let id: Int
    let name: String
    let category: Category
    let coordinate: String
    let itinerary: Int?
    
    let sizeGrowth: Double = 1
    
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
