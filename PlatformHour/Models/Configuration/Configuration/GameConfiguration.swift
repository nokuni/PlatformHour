//
//  GameConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import PlayfulKit

public struct GameConfiguration {
    
    // MARK: Keys
    static let soundKey = SoundKey()
    static let nodeKey = NodeKey()
    static let imageKey = ImageKey()
    static let jsonKey = JSONKey()
    
    // MARK: - Configurations
    static let worldConfiguration = WorldConfiguration()
    static let sceneConfiguration = SceneConfiguration()
    static let playerConfiguration = PlayerConfiguration()
    static let animationConfiguration = AnimationConfiguration()
    
    // MARK: - Managers
    static let assemblyManager = AssemblyManager()
}
