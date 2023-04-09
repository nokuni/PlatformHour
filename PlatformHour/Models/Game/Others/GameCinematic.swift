//
//  GameCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct GameCinematic {
    let name: String
    let actions: [GameCharacterCinematicAction]
}

// Character(s) doing a sequence of actions ?
// Dialog ?
// Repeat ?

// Movement
// State ID
// ending position

struct GameCharacterCinematicAction {
    let id: Int
    let objectName: String
    let stateIDIdentifier: String
    let startingCoordinate: String?
    let destinationCoordinate: String
    let isFollowedByCamera: Bool
}
