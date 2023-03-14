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
    public var isFollowingPlayer: Bool = true

    private let zoom = UIDevice.isOnPhone ? 1.1 : 1.25
    private let catchUpDelay: CGFloat = 0
    
    private var adjustement: CGFloat {
        return UIDevice.isOnPhone ? (CGSize.screen.height * 0.2) : (CGSize.screen.height * 0.3)
    }
    
    private var position : CGPoint {
        guard let playerCoordinate = scene.game?.playerCoordinate else { return .zero }
        guard let position = environment.map.tilePosition(from: playerCoordinate) else { return .zero }
        let adjustedPosition = CGPoint(x: position.x, y: position.y + adjustement)
        return adjustedPosition
    }
    
    private var playerPosition: CGPoint {
        guard let player = scene.player else { return .zero }
        return CGPoint(x: player.node.position.x, y: player.node.position.y + adjustement)
    }
    
    private func configure() {
        isFollowingPlayer = true
        camera.scene = scene
        camera.position = position
        camera.zoom = zoom
        camera.add()
    }
    
    public func followPlayer() {
        guard let action = scene.game?.controller?.action else { return }
        guard isFollowingPlayer else { return }
        guard scene.isExistingChildNode(named: "Player") else { return }
        guard action.isAnimating else { return }
        
        let minCameraPosition = environment.map.tilePosition(from: Coordinate(x: 13, y: 8))
        let maxCameraPosition = environment.map.tilePosition(from: Coordinate(x: 13, y: 41))
        
        if let minCameraPosition, let maxCameraPosition {
            if (playerPosition.x > minCameraPosition.x) && (playerPosition.x < maxCameraPosition.x) {
                camera.move(to: playerPosition, catchUpDelay: catchUpDelay)
            }
        }
    }
}
