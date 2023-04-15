//
//  GameCharacterCinematicActionMovement.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 12/04/23.
//

import Foundation

struct GameCharacterCinematicActionMovement: Codable {
    let destinationCoordinate: String
    let duration: Double
    let willDisappear: Bool
}
