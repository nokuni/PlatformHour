//
//  GameCamera.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameCamera {
    
    init(scene: SKScene) {
        self.scene = scene
        setUpCamera()
    }
    
    var scene: SKScene?
    
    var position : CGPoint {
        guard let scene = scene as? GameScene else { return CGPoint.zero }
        return UIDevice.isOnPhone ?
        CGPoint(x: scene.player.node.position.x, y: scene.player.node.position.y + (CGSize.screen.height * 0.2)) :
        CGPoint(x: scene.player.node.position.x, y: scene.player.node.position.y + (CGSize.screen.height * 0.3))
    }
    var zoom : CGFloat { return UIDevice.isOnPhone ? 1.5 : 1.25 }
    
    var catchUpDelay: CGFloat = 0.1
    
    func setUpCamera() {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        let cameraNode = SKCameraNode()
        
        scene.addChild(cameraNode)
        scene.camera = cameraNode
        
        let repositioning = UIDevice.isOnPhone ? CGSize.screen.height * 0.2 : CGSize.screen.height * 0.3
        scene.camera?.position = CGPoint(x: scene.frame.minX + dimension.tileSize.width, y: scene.frame.minY + dimension.tileSize.height + repositioning)
        
        let zoomInAction = SKAction.scale(to: zoom, duration: 0)
        cameraNode.run(zoomInAction)
    }
    
    func followPlayer() {
        guard let scene = scene as? GameScene else { return }
        guard let content = scene.content?.all else { return }
        guard content.isExisting("Player") else { return }
        scene.camera?.run(SKAction.move(to: position, duration: catchUpDelay))
    }
}
