//
//  GameCharacterCinematicActionEffect.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 12/04/23.
//

import Foundation

struct GameCharacterCinematicActionEffect: Codable {
    let stateIDIdentifier: String
    let sizeGrowth: Double?
    let repeatCount: Int?
    let isRepeatingForever: Bool
}
