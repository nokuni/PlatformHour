//
//  GameState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit

class GameState: ObservableObject {
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    @Published var status: Status = .inGame
    
    enum Status {
        case inGame
        case inPause
    }
}
