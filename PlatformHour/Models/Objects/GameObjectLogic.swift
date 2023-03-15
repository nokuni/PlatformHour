//
//  GameObjectLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

struct GameObjectLogic: Codable {
    var health: Int
    var damage: Int
    var isDestructible: Bool
    var isIntangible: Bool
    
    enum CodingKeys: String, CodingKey {
        case health, damage, isDestructible, isIntangible
    }
}
