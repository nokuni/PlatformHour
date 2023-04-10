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
        case inDialog
        case inCinematic
        case inPause
    }
    
    public func switchOn(newStatus: Status) {
        previousStatus = status
        status = newStatus
    }
    
    public func switchOnPreviousStatus() {
        if let previousStatus = previousStatus {
            status = previousStatus
        }
    }
}
