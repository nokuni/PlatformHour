//
//  LevelObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import PlayfulKit
import Utility_Toolbox

struct LevelObject: Codable, LevelProtocol {
    let id: Int
    let name: String
    let category: Category
    let coordinate: String
    let itinerary: Int?
    @DecodableDefault.OneFloat var sizeGrowth: Double
    @DecodableDefault.True var hasCollisionTailoring: Bool
    let speed: Double?
    @DecodableDefault.False var isRespawning: Bool
    
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
        case hasCollisionTailoring
        case speed
        case isRespawning
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
