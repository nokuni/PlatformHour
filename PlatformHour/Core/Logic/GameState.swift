//
//  GameState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit

public class GameState {
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    public var status: Status = .inGame
    
    public enum Status {
        case inGame
        case inPause
    }
}
