//
//  GameCamera.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameCamera {
    
    public init(scene: GameScene, environment: GameEnvironment) {
        self.scene = scene
        self.environment = environment
        configure()
    }
    
    public var scene: GameScene
    public var environment: GameEnvironment
    
    public var camera = CameraManager()
    
    private let zoom = UIDevice.isOnPhone ? 1.1 : 1.25
    private let catchUpDelay: CGFloat = 0
    
    private var position : CGPoint {
        let mapTileNode = environment.map.tileNode(at: scene.game.playerCoordinate)
        let mapTilePosition = mapTileNode?.position ?? .zero
        return UIDevice.isOnPhone ?
        CGPoint(x: mapTilePosition.x, y: mapTilePosition.y + (CGSize.screen.height * 0.2)) :
        CGPoint(x: mapTilePosition.x, y: mapTilePosition.y + (CGSize.screen.height * 0.3))
    }
    private var playerPosition: CGPoint {
        return UIDevice.isOnPhone ?
        CGPoint(x: scene.player.node.position.x, y: scene.player.node.position.y + (CGSize.screen.height * 0.2)) :
        CGPoint(x: scene.player.node.position.x, y: scene.player.node.position.y + (CGSize.screen.height * 0.3))
    }
    
    private func configure() {
        camera.scene = scene
        camera.position = position
        camera.zoom = zoom
        camera.catchUpDelay = catchUpDelay
        camera.add()
    }
    
    public func followPlayer() {
        guard scene.isExistingChildNode(named: "Player") else { return }
        camera.move(to: playerPosition)
    }
}
