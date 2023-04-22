//
//  LevelObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import PlayfulKit

struct LevelObject: Codable, LevelProtocol {
    let id: Int
    let name: String
    let category: Category
    let coordinate: String
    let itinerary: Int?
    let sizeGrowth: Double?
    let speed: Double?
    var isFalling: Bool?
    
    enum Category: String, Codable {
        case player
        case important
        case npc
        case enemy
        case trap
        case collectible
        case interactive
        case obstacle
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case coordinate
        case itinerary
        case sizeGrowth
        case speed
        case isFalling
    }
}

extension LevelObject {
    
    /// Returns a level element indexed by his ID.
    static func indexedObjectNode<Element: LevelProtocol>(object: PKObjectNode,
                                                          data: [Element]) -> Element? {
        guard let objectName = object.name else { return nil }
        guard let id = objectName.extractedNumber else { return nil }
        let element = data.first(where: { $0.id == id })
        return element
    }
}
