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
    
    let manager = SoundManager()
    
    public func step() {
        try? manager.playSFX(name: GameConfiguration.soundConfigurationKey.diceRoll, volume: 0.1)
    }
    
    public func land() {
        try? manager.playSFX(name: "diceFallCavern.wav", volume: 0.1)
    }
    
    public func playBackgroundMusic() {
        try? manager.playMusicSequence(names: ["cavernAmbient1.wav",
                                               "cavernAmbient2.wav"],
                                       volume: 1)
    }
}
