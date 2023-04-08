//
//  LevelObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

public struct LevelObject: Codable, LevelProtocol {
    public init(id: Int,
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
    
    public let id: Int
    public let name: String
    public let category: Category
    public let coordinate: String
    public let itinerary: Int?
    
    public let sizeGrowth: Double = 1
    
    public enum Category: String, Codable {
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
