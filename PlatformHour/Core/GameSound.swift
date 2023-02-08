//
//  GameSound.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameSound {
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    let kit = PKSound()
    
    func step() {
        kit.playSFX(name: "diceRoll.wav", loops: 1, volume: 0.1)
    }
    
}
