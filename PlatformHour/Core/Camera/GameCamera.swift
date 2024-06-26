//
//  GameCamera.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final class GameCamera {
    
    init(scene: GameScene, environment: GameEnvironment) {
        self.scene = scene
        self.environment = environment
        camera = CameraManager(scene: scene)
        configure()
    }
    
    var scene: GameScene
    var environment: GameEnvironment
    
    var camera: CameraManager
    var isUpdatingMovement: Bool = false
    var followedObject: PKObjectNode?
    
    private let zoom = GameConfiguration.sceneConfiguration.cameraZoom
    private let catchUpDelay: CGFloat = GameConfiguration.sceneConfiguration.cameraCatchUpDelay
}

// MARK: - Configurations

extension GameCamera {
    
    /// Returns the value to reposition the camera.
    var adjustement: CGFloat {
        GameConfiguration.sceneConfiguration.cameraAdjustement
    }
    
    /// Returns the current position of the followed node.
    private var position : CGPoint {
        guard let followedObject = followedObject else { return .zero }
        let adjustedPosition = CGPoint(x: followedObject.position.x,
                                       y: followedObject.position.y + adjustement)
        return adjustedPosition
    }
    
    /// Configure the current camera on the scene.
    private func configure() {
        guard let player = scene.player else { return }
        isUpdatingMovement = true
        followedObject = player.node
        camera.configure(configuration: .init(position: position, zoom: zoom))
    }
    
    /// Set the limit of the camera.
    private func limitOnBounds() {
        
        guard let topLimit = environment.mapLimits.top else { return }
        guard let rightLimit = environment.mapLimits.right else { return }
        guard let bottomLimit = environment.mapLimits.bottom else { return }
        guard let leftLimit = environment.mapLimits.left else { return }
        
        let minimumCoordinate = Coordinate(x: topLimit, y: leftLimit)
        let maximumCoordinate = Coordinate(x: bottomLimit, y: rightLimit)
        
        guard let minCameraPosition = environment.map.tilePosition(from: minimumCoordinate) else { return }
        guard let maxCameraPosition = environment.map.tilePosition(from: maximumCoordinate) else { return }
        
        if position.x < minCameraPosition.x {
            camera.move(to: CGPoint(x: minCameraPosition.x, y: position.y), catchUpDelay: GameConfiguration.sceneConfiguration.cameraCatchUpDelay)
        }
        
        if position.x > maxCameraPosition.x {
            camera.move(to: CGPoint(x: maxCameraPosition.x, y: position.y), catchUpDelay: GameConfiguration.sceneConfiguration.cameraCatchUpDelay)
        }
        
        if position.y > minCameraPosition.y {
            camera.scene.camera?.run(SKAction.moveTo(y: minCameraPosition.y, duration: GameConfiguration.sceneConfiguration.cameraCatchUpDelay))
        }
        
        if position.y < maxCameraPosition.y {
            camera.scene.camera?.run(SKAction.moveTo(y: maxCameraPosition.y, duration: GameConfiguration.sceneConfiguration.cameraCatchUpDelay))
        }
    }
}

// MARK: - Actions

extension GameCamera {
    
    /// Follow the current selected object.
    func follow() {
        guard isUpdatingMovement else { return }
        camera.move(to: position, catchUpDelay: catchUpDelay)
        limitOnBounds()
    }
}
