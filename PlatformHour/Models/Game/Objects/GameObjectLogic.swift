//
//  GameObjectLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

struct GameObjectLogic: Codable {
    init(health: Int,
                damage: Int,
                isDestructible: Bool,
                isIntangible: Bool) {
        self.health = health
        self.damage = damage
        self.isDestructible = isDestructible
        self.isIntangible = isIntangible
    }
    
    var health: Int
    var damage: Int
    var isDestructible: Bool
    var isIntangible: Bool
    
    enum CodingKeys: String, CodingKey {
        case health, damage, isDestructible, isIntangible
    }
}
