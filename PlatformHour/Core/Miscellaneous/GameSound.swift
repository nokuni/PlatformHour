//
//  GameSound.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameSound {
    public init(scene: SKScene) {
        self.scene = scene
    }
    
    public var scene: SKScene?
    private let manager = SoundManager()
    
    public func step() {
        manager.playSFX(name: "diceRoll.wav", loops: 1, volume: 0.1)
    }
    
}
