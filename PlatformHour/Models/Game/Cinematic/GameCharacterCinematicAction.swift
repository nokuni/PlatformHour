//
//  GameCharacterCinematicAction.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/04/23.
//

import Foundation

public struct GameCharacterCinematicAction: Codable {
    public init(id: Int,
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
    
    public let id: Int
    public let objectName: String
    public let startingCoordinate: String?
    public let movement: GameCharacterCinematicActionMovement?
    public let effect: GameCharacterCinematicActionEffect?
    public let isFollowedByCamera: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case objectName
        case startingCoordinate
        case movement
        case effect
        case isFollowedByCamera
    }
}
