//
//  GameConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import PlayfulKit

public struct GameConfiguration {
    
    static let soundConfigurationKey = SoundConfigurationKey()
    static let sceneConfigurationKey = NodeConfigurationKey()
    static let imageConfigurationKey = ImageConfigurationKey()
    static let jsonConfigurationKey = JSONConfigurationKey()
    
    static let worldConfiguration = WorldConfiguration()
    static let sceneConfiguration = SceneConfiguration()
    static let playerConfiguration = PlayerConfiguration()
    static let animationConfiguration = AnimationConfiguration()
    
    static let assemblyManager = AssemblyManager()
}
