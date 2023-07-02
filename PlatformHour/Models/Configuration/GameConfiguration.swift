//
//  GameConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import PlayfulKit
import Utility_Toolbox

struct GameConfiguration {
    
    // MARK: Keys
    static let soundKey = SoundKey()
    static let nodeKey = NodeKey()
    static let imageKey = ImageKey()
    static let jsonKey = JSONKey()
    
    // MARK: - Configurations
    static let sceneConfiguration = SceneConfiguration()
    static let playerConfiguration = PlayerConfiguration()
    
    // MARK: - Managers
    static let assemblyManager = AssemblyManager()
    static let bundleManager = BundleManager()
    
    static let startingWorldID = 0
    static let startingLevelID = 0
}
