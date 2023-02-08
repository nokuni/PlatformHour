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
    let kit = PKMatrix()
    
    var leftLimit: CGFloat {
        guard let scene = scene as? GameScene else { return 0 }
        return scene.frame.minX
    }
    var rightLimit: CGFloat {
        guard let scene = scene as? GameScene else { return 0 }
        return scene.player.node.size.width * 30
    }
    
    var tileSize: CGSize {
        return UIDevice.isOnPhone ?
        CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
        CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    }
}
