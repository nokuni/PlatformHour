//
//  GameObjectLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

public struct GameObjectLogic: Codable {
    public init(health: Int,
                damage: Int,
                isDestructible: Bool,
                isIntangible: Bool) {
        self.health = health
        self.damage = damage
        self.isDestructible = isDestructible
        self.isIntangible = isIntangible
    }
    
    public var health: Int
    public var damage: Int
    public var isDestructible: Bool
    public var isIntangible: Bool
    
    enum CodingKeys: String, CodingKey {
        case health, damage, isDestructible, isIntangible
    }
}
