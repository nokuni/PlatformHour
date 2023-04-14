//
//  GameState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit

public final class GameState {
    
    public init() { }
    
    public var status: Status = .inDefault
    public var previousStatus: Status?
    
    public enum Status {
        case inDefault
        case inAction
        case inConversation
        case inCinematic
        case inPause
    }
}

// MARK: - Updates

public extension GameState {
    
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
