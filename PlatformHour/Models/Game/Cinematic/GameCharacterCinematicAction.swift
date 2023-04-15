//
//  GameCharacterCinematicAction.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/04/23.
//

import Foundation

struct CinematicAction: Codable {
    init(id: Int,
                objectName: String,
                startingCoordinate: String?,
                movement: GameCharacterCinematicActionMovement,
                effect: GameCharacterCinematicActionEffect,
                isFollowedByCamera: Bool) {
        self.id = id
        self.objectName = objectName
        self.startingCoordinate = startingCoordinate
        self.movement = movement
        self.effect = effect
        self.isFollowedByCamera = isFollowedByCamera
    }
    
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
