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
        createEnvironment()
    }
    
    public var scene: GameScene
    public var map = PKMapNode()
    public var backgroundContainer = SKNode()
    
    public var mapMatrix: Matrix {
        guard let matrix = scene.game?.level?.mapMatrix.matrix else { return .zero }
        return Matrix(row: matrix.row, column: matrix.column)
    }
    
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
    
    public var deathLimit: Int {
        mapMatrix.row - 1
    }
    
    public var allElements: [SKSpriteNode] {
        let allTiles = map.tiles
        let allObjects = map.objects
        let allElements = allTiles + allObjects
        return allElements
    }
    public var collisionCoordinates: [Coordinate] {
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    public var backgroundSize: CGSize {
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let width = tileSize.width * 13
        let height = tileSize.height * 9
        return CGSize(width: width, height: height)
    }
    
    public func isCollidingWithObject(at coordinate: Coordinate) -> Bool {
        collisionCoordinates.contains(coordinate)
    }
    
    // MARK: - Main
    private func createEnvironment() {
        createMap()
        createBackground()
    }
    
    // MARK: - Elements
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
    
    public func backgroundObjectElement(name: String? = nil,
                                        physicsBodySizeTailoring: CGFloat = 0,
                                        collision: Collision) -> PKObjectNode {
        let structureElement = objectElement(name: name,
                                             physicsBodySizeTailoring: physicsBodySizeTailoring,
                                             collision: collision)
        structureElement.blendMode = .alpha
        structureElement.name = name
        structureElement.zPosition = GameConfiguration.sceneConfiguration.backgroundZPosition
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        return structureElement
    }
    
    // MARK: - Background
    private func createBackground() {
        if let level = scene.game?.level {
            backgroundContainer.name = GameConfiguration.sceneConfigurationKey.background
            scene.addChildSafely(backgroundContainer)
            let tileSize = GameConfiguration.worldConfiguration.tileSize
            let centerPosition = map.centerPosition
            let adjustement = GameConfiguration.worldConfiguration.tileSize.height * 5
            let background = SKSpriteNode(imageNamed: level.background)
            background.texture?.filteringMode = .nearest
            background.size = CGSize(width: tileSize.width * CGFloat(map.matrix.column),
                                     height: tileSize.width * CGFloat(map.matrix.row - 10))
            background.position = CGPoint(x: centerPosition.x, y: centerPosition.y + adjustement)
            backgroundContainer.addChildSafely(background)
        }
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: GameConfiguration.worldConfiguration.tileSize,
                        matrix: mapMatrix)
        let texture = SKTexture(imageNamed: "leadSquare")
        texture.filteringMode = .nearest
        map.drawTexture(texture)
        scene.addChild(map)
    }
    
    // MARK: - Miscellaneous
    private func controllerButtonSprites(_ buttonSymbol: ControllerManager.ButtonSymbol) -> [String]? {
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
    
    public func showStatueInteractionPopUp() {
        guard let exit = scene.game?.level?.exit else { return }
        
        if let position = map.tilePosition(from: exit.coordinate.coordinate) {
            let buttonPosition = CGPoint(x: position.x, y: position.y + (GameConfiguration.worldConfiguration.tileSize.height * 2))
            createButtonPopUp(buttonSymbol: .y, position: buttonPosition)
        }
    }
    
    private func createButtonPopUp(buttonSymbol: ControllerManager.ButtonSymbol, position: CGPoint) {
        
        let buttonPopUp = SKNode()
        buttonPopUp.name = "Button pop up"
        scene.addChildSafely(buttonPopUp)
        
        let button = SKSpriteNode()
        button.size = GameConfiguration.worldConfiguration.tileSize
        button.setScale(0.6)
        button.position = position
        buttonPopUp.addChildSafely(button)
        
        if let sprites = controllerButtonSprites(buttonSymbol) {
            let action = SKAction.animate(with: sprites, filteringMode: .nearest, timePerFrame: 0.5)
            button.run(SKAction.repeatForever(action))
        }
    }
    
    public func pause() { map.isPaused = true }
    
    public func unpause() { map.isPaused = false }
}
