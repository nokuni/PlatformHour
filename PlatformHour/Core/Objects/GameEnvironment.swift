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
        generateEnvironment()
    }
    
    public var scene: GameScene
    public var map = PKMapNode()
    public var backgroundContainer = SKNode()
    
    /// Current map.
    public var mapMatrix: Matrix {
        guard let matrix = scene.game?.level?.mapMatrix.matrix else { return .zero }
        return Matrix(row: matrix.row, column: matrix.column)
    }
    
    /// Limits on the current map.
    public var mapLimits: (top: Int?, right: Int?, bottom: Int?, left: Int?) {
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
    public var deathLimit: Int {
        mapMatrix.row - 1
    }
    
    /// Returns all tiles and objects on the current map.
    public var allElements: [SKSpriteNode] {
        let allTiles = map.tiles
        let allObjects = map.objects
        let allElements = allTiles + allObjects
        return allElements
    }
    
    /// Returns coordinates from the objects on the current map.
    public var collisionCoordinates: [Coordinate] {
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    
    /// Returns true there is a collision with an object at a coordinate, false otherwise.
    public func isCollidingWithObject(at coordinate: Coordinate) -> Bool {
        collisionCoordinates.contains(coordinate)
    }
    
    // MARK: - Main
    private func generateEnvironment() {
        generateMap()
        generateBackground()
    }
    
    // MARK: - Elements
    
    /// Returns an unconfigured object node.
    public func objectElement(name: String? = nil,
                              physicsBodySizeTailoring: CGFloat = 0,
                              collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = GameConfiguration.worldConfiguration.tileSize
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    
    /// Returns an object node configured for structures.
    public var structureObjectElement: PKObjectNode {
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
    
    // MARK: - Generations
    
    /// Generate the current map.
    private func generateMap() {
        map = PKMapNode(squareSize: GameConfiguration.worldConfiguration.tileSize,
                        matrix: mapMatrix)
        let texture = SKTexture(imageNamed: "leadSquare")
        texture.filteringMode = .nearest
        map.drawTexture(texture)
        scene.addChildSafely(map)
    }
    
    /// Generate the current background.
    private func generateBackground() {
        if let level = scene.game?.level {
            backgroundContainer.name = GameConfiguration.nodeKey.background
            scene.addChildSafely(backgroundContainer)
            let tileSize = GameConfiguration.worldConfiguration.tileSize
            let centerPosition = map.centerPosition
            let adjustement = GameConfiguration.worldConfiguration.tileSize.height * CGFloat(level.background.adjustement)
            let background = SKSpriteNode(imageNamed: level.background.image)
            background.texture?.filteringMode = .nearest
            background.size = CGSize(width: tileSize.width * CGFloat(map.matrix.column),
                                     height: tileSize.width * CGFloat(map.matrix.row - level.background.adjustement))
            background.position = CGPoint(x: centerPosition.x, y: centerPosition.y + adjustement)
            backgroundContainer.addChildSafely(background)
        }
    }
    
    /// Generate an animated pop up controller button.
    public func generatePopUpButton(buttonSymbol: ControllerManager.ButtonSymbol, position: CGPoint) {
        
        let popUpButton = SKNode()
        popUpButton.name = GameConfiguration.nodeKey.popUpButton
        scene.addChildSafely(popUpButton)
        
        let button = SKSpriteNode()
        button.size = GameConfiguration.worldConfiguration.tileSize
        button.setScale(0.6)
        button.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        button.position = position
        popUpButton.addChildSafely(button)
        
        if let sprites = controllerButtons(buttonSymbol) {
            print(sprites)
            let action = SKAction.animate(with: sprites, filteringMode: .nearest, timePerFrame: 0.5)
            button.run(SKAction.repeatForever(action))
        }
    }
    
    // MARK: - Miscellaneous
    
    /// Pause the current map.
    public func pause() { map.isPaused = true }
    
    /// Unpause the current map.
    public func unpause() { map.isPaused = false }
}
