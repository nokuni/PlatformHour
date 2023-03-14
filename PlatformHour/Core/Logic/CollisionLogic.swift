//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class CollisionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    
    public func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        scene.core?.logic?.damageObject(objectNode, with: projectileNode)
    }
    
    public func pickUpItem(object: PKObjectNode, name: String) {
        if let item = try? GameItem.get(name) {
            scene.player?.bag.append(item)
            scene.core?.hud?.updateItemAmountHUD()
            object.removeFromParent()
            scene.core?.content?.createPortal()
        }
    }
}
