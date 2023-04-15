//
//  GameCharacterCinematicAction.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/04/23.
//

import Foundation

struct CinematicAction: Codable {
    let id: Int
    let objectName: String
    let startingCoordinate: String?
    let movement: GameCharacterCinematicActionMovement?
    let effect: GameCharacterCinematicActionEffect?
    let isFollowedByCamera: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case objectName
        case startingCoordinate
        case movement
        case effect
        case isFollowedByCamera
    }
}
