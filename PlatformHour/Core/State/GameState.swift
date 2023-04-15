//
//  GameState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit

final class GameState {
    
    init() { }
    
    var status: Status = .inDefault
    var previousStatus: Status?
    
    enum Status {
        case inDefault
        case inAction
        case inConversation
        case inCinematic
        case inPause
    }
}

// MARK: - Updates

extension GameState {
    
    /// Switch the current game state to a new one.
    func switchOn(newStatus: Status) {
        previousStatus = status
        status = newStatus
    }
    
    /// Switch the current game state to the previous one.
    func switchOnPreviousStatus() {
        guard let previousStatus = previousStatus else { return }
        status = previousStatus
    }
}
