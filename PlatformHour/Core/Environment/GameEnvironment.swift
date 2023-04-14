//
//  GameEnvironment.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameEnvironment {
    
    public init(scene: GameScene) {
        self.scene = scene
        generate()
    }
    
    public var scene: GameScene
    public var map = PKMapNode()
    public var backgroundContainer = SKNode()
    
    private func generate() {
        createMap()
        createBackground()
    }
}

// MARK: - Informations

public extension GameEnvironment {
    /// Current map.
    var mapMatrix: Matrix {
        guard let matrix = scene.game?.level?.mapMatrix.matrix else { return .zero }
        return Matrix(row: matrix.row, column: matrix.column)
    }
    
    /// Limits on the current map.
    var mapLimits: (top: Int?, right: Int?, bottom: Int?, left: Int?) {
        let playerCoordinate = scene.game?.level?.playerCoordinate.coordinate
        
        let top = 4
        let right = mapMatrix.column - 9
        let bottom = mapMatrix.row - 6
        let left = playerCoordinate?.y
        
        //        let leftBoundaryLimit: Int = 8
        //        let rightBoundaryLimit: Int = 51
        //        let topBoundaryLimit: Int = 4
        //        let bottomBoundaryLimit: Int = 34
        
        return (top, right, bottom, left)
    }
    
    /// Death limit of the current map.
    var deathLimit: Int {
        mapMatrix.row - 1
    }
    
    /// Returns all tiles and objects on the current map.
    var allElements: [SKSpriteNode] {
        let allTiles = map.tiles
        let allObjects = map.objects
        let allElements = allTiles + allObjects
        return allElements
    }
    
    /// Returns coordinates from the objects on the current map.
    var collisionCoordinates: [Coordinate] {
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    
    /// Returns true there is a collision with an object at a coordinate, false otherwise.
    func isCollidingWithObject(at coordinate: Coordinate) -> Bool {
        collisionCoordinates.contains(coordinate)
    }
}

// MARK: - Elements

public extension GameEnvironment {
    /// Returns an unconfigured object node.
    func objectElement(name: String? = nil,
                       physicsBodySizeTailoring: CGFloat = 0,
                       collision: Collision) -> PKObjectNode {
        
        let texture = SKTexture()
        let object = PKObjectNode(texture: texture, size: map.squareSize)
        object.name = name
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    
    /// Returns an object node configured for structures.
    var structureObjectElement: PKObjectNode {
        let collision = Collision(category: .structure,
                                  collision: [.player, .object, .playerProjectile, .enemyProjectile],
                                  contact: [.player, .object, .playerProjectile, .enemyProjectile])
        let structureElement = objectElement(collision: collision)
        structureElement.zPosition = GameConfiguration.sceneConfiguration.sceneryZPosition
        structureElement.physicsBody?.friction = 0
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        structureElement.physicsBody?.usesPreciseCollisionDetection = true
        return structureElement
    }
    
    /// Returns the controller button image names of a button. (The image names are different depending on the current connected gamepad).
    private func controllerButtons(_ buttonSymbol: ControllerManager.ButtonSymbol) -> [String]? {
        guard let controllerManager = scene.game?.controller?.manager else {
            return nil
        }
        switch buttonSymbol {
        case .a:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.a, of: .xbox)
            case .playstation:
                return ControllerButton.button(.a, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.a, of: .nintendo)
            case .none:
                return ControllerButton.button(.a, of: .nintendo)
            }
        case .b:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.b, of: .xbox)
            case .playstation:
                return ControllerButton.button(.b, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.b, of: .nintendo)
            case .none:
                return ControllerButton.button(.b, of: .nintendo)
            }
        case .x:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.x, of: .xbox)
            case .playstation:
                return ControllerButton.button(.x, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.x, of: .nintendo)
            case .none:
                return ControllerButton.button(.x, of: .nintendo)
            }
        case .y:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.y, of: .xbox)
            case .playstation:
                return ControllerButton.button(.y, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.y, of: .nintendo)
            case .none:
                return ControllerButton.button(.y, of: .nintendo)
            }
        }
    }
}

// MARK: - Creations

public extension GameEnvironment {
    /// Generate the current map.
    private func createMap() {
        map = PKMapNode(squareSize: GameConfiguration.sceneConfiguration.tileSize,
                        matrix: mapMatrix)
        map.zPosition = GameConfiguration.sceneConfiguration.mapZPosition
        let texture = SKTexture(imageNamed: GameConfiguration.imageKey.mapSquare)
        texture.filteringMode = .nearest
        map.drawTexture(texture)
        scene.addChildSafely(map)
    }
    
    /// Generate the current background.
    private func createBackground() {
        if let level = scene.game?.level {
            backgroundContainer.name = GameConfiguration.nodeKey.background
            scene.addChildSafely(backgroundContainer)
            let background = background(level: level)
            backgroundContainer.addChildSafely(background)
        }
    }
    
    /// Returns the level background.
    private func background(level: GameLevel) -> SKSpriteNode {
        let centerPosition = map.centerPosition
        let adjustement = map.squareSize.height * CGFloat(level.background.adjustement)
        let background = SKSpriteNode(imageNamed: level.background.image)
        background.blendMode = .replace
        background.texture?.filteringMode = .nearest
        background.texture?.preload { }
        background.size = CGSize(width: map.squareSize.width * CGFloat(map.matrix.column),
                                 height: map.squareSize.width * CGFloat(map.matrix.row - level.background.adjustement))
        background.zPosition = GameConfiguration.sceneConfiguration.backgroundZPosition
        background.position = CGPoint(x: centerPosition.x, y: centerPosition.y + adjustement)
        return background
    }
    
    /// Generate an animated pop up controller button.
    func createPopUpButton(buttonSymbol: ControllerManager.ButtonSymbol, position: CGPoint) {
        
        let popUpButton = SKNode()
        popUpButton.name = GameConfiguration.nodeKey.popUpButton
        scene.addChildSafely(popUpButton)
        
        let button = SKSpriteNode()
        button.size = GameConfiguration.sceneConfiguration.tileSize
        button.setScale(0.6)
        button.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        button.position = position
        popUpButton.addChildSafely(button)
        
        if let sprites = controllerButtons(buttonSymbol) {
            let action = SKAction.animate(with: sprites, filteringMode: .nearest, timePerFrame: 0.5)
            button.run(SKAction.repeatForever(action))
        }
    }
}

// MARK: - Miscellaneous

public extension GameEnvironment {
    /// Pause the current map.
    func pause() { map.isPaused = true }
    
    /// Unpause the current map.
    func unpause() { map.isPaused = false }
}
