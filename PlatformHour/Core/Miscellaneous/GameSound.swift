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
        manager.playSFX(name: GameConfiguration.soundConfigurationKey.diceRoll, loops: 1, volume: GameConfiguration.worldConfiguration.soundSFXVolume)
    }
    
    public func playBackgroundMusic() {
        manager.playMusic(name: "cavernAmbient0", volume: GameConfiguration.worldConfiguration.soundSFXVolume, loops: 1)
    }
}
