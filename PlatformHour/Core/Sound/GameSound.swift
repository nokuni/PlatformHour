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
    
}

// MARK: - SFX

public extension GameSound {
    
    /// Play a step sound.
    func step() {
        try? manager.playSFX(name: GameConfiguration.soundKey.playerStep, volume: GameConfiguration.sceneConfiguration.soundStepVolume)
    }
    
    /// Play a landing sound.
    func land(scene: GameScene) {
        if let landSound = scene.game?.world?.playerLandSound {
            try? manager.playSFX(name: landSound, volume: GameConfiguration.sceneConfiguration.soundFallVolume)
        }
    }
}

// MARK: - Music

public extension GameSound {
    
    /// Play background musics..
    func playBackgroundMusics(scene: GameScene) {
        if let musics = scene.game?.level?.musics {
            try? manager.playMusicSequence(names: musics, volume: GameConfiguration.sceneConfiguration.soundBackgroundVolume)
        }
    }
}
