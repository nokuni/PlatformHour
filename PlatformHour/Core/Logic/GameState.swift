//
//  GameState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit

public final class GameState {
    
    public init() { }
    
    public var status: Status = .inGame
    
    public enum Status {
        case inGame
        case inPause
    }
}
