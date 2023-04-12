//
//  GameSound.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameSound {
    
    public init() { }
    
    public let manager = SoundManager()
    
    /// Play a step sound.
    public func step() {
        try? manager.playSFX(name: GameConfiguration.soundKey.playerStep, volume: 0.1)
    }
    
    /// Play a landing sound.
    public func land(scene: GameScene) {
        if let landSound = scene.game?.world?.playerLandSound {
            try? manager.playSFX(name: landSound, volume: 0.1)
        }
    }
    
    /// Play background musics..
    public func playBackgroundMusics(scene: GameScene) {
        if let musics = scene.game?.level?.musics {
            try? manager.playMusicSequence(names: musics, volume: 1)
        }
    }
}
