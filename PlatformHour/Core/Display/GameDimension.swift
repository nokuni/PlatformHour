//
//  GameDimension.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 03/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameDimension {
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    let assembly = AssemblyManager()
    
    var tileSize: CGSize {
        return UIDevice.isOnPhone ?
        CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
        CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    }
}
