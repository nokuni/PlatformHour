//
//  BugFile.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SwiftUI

// MARK: - IMPORTANT

// Hardware Game Controller does not work after completing a level

// The player can't move at least 1 when he can't move 2.

// MARK: - NOT IMPORTANT

// Make the vase death animation more faster to not block the player when he moves.

struct GameApp {
    static let soundConfigurationKey = SoundConfigurationKey()
    static let sceneConfigurationKey = SceneConfigurationKey()
    static let imageConfigurationKey = ImageConfigurationKey()
    static let jsonConfigurationKey = JSONConfigurationKey()
    static let worldConfiguration = WorldConfiguration()
    static let playerConfiguration = PlayerConfiguration()
}

struct SoundConfigurationKey {
    let diceRoll = "diceRoll.wav"
}

struct SceneConfigurationKey {
    let buttonPopUp = "Button pop up"
    let requirementPopUp = "Requirement pop up"
    let number = "Number"
    let player = "Player"
    let playerArrow = "Player Arrow"
    let playerProjectile = "Player Projectile"
    let statue = "Statue"
    let pillar = "Pillar"
}

struct ImageConfigurationKey {
    let rightArrow = "arrowRight"
    let leftArrow = "arrowLeft"
    let upArrow = "arrowUp"
    let downArrow = "arrowDown"
    let indicator = "indicator"
}

struct JSONConfigurationKey {
    let objects = "objects.json"
    let items = "items.json"
    let levels = "levels.json"
    let worlds = "worlds.json"
    let structures = "structures.json"
    let controllerButtons = "controllerButtons.json"
    let spriteAnimations = "spriteAnimations.json"
}

struct PlayerConfiguration {
    let range: CGFloat = 5
    let attackSpeed: CGFloat = 0.5
    let runTimePerFrame: TimeInterval = 0.05
    let runRightAnimation = "Dice Run Right"
    let runLeftAnimation = "Dice Run Left"
}

struct WorldConfiguration {
    let gravity = CGVector(dx: 0, dy: -10)
    let cameraZoom = UIDevice.isOnPhone ? 1.1 : 1.25
    let cameraCatchUpDelay: CGFloat = 0
    let cameraAdjustement: CGFloat = UIDevice.isOnPhone ?
    (CGSize.screen.height * 0.2) :
    (CGSize.screen.height * 0.3)
    let tileSize = UIDevice.isOnPhone ?
    CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
    CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    let soundSFXVolume: Float = 0.1
}
