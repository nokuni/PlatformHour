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
    public var mapMatrix = Matrix(row: 40, column: 60)
    
    
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
        structureElement.zPosition = GameConfiguration.worldConfiguration.sceneryZPosition
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
        structureElement.zPosition = GameConfiguration.worldConfiguration.backgroundZPosition
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        return structureElement
    }
    
    // MARK: - Background
    private func createBackground() {
        backgroundContainer.name = GameConfiguration.sceneConfigurationKey.background
        scene.addChildSafely(backgroundContainer)
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let centerPosition = map.centerPosition()
        let adjustement = GameConfiguration.worldConfiguration.tileSize.height * 5
        let background = SKSpriteNode(imageNamed: "caveBackground")
        background.texture?.filteringMode = .nearest
        background.size = CGSize(width: tileSize.width * CGFloat(map.matrix.column),
                                 height: tileSize.width * CGFloat(map.matrix.row - 10))
        background.position = CGPoint(x: centerPosition.x, y: centerPosition.y + adjustement)
        backgroundContainer.addChildSafely(background)
//        createSky()
    }
    
    private func createSky() {
        guard let skyPosition = map.tilePosition(from: Coordinate(x: 12, y: 6)) else { return }
        guard let highSkyPosition = map.tilePosition(from: Coordinate(x: 4, y: 6)) else { return }
        guard let lowSkyPosition = map.tilePosition(from: Coordinate(x: 23, y: 6)) else { return }
        
        var skyBackgrounds: [SKSpriteNode] = []
        var highSkyBackgrounds: [SKSpriteNode] = []
        var lowSkyBackgrounds: [SKSpriteNode] = []
        
        for _ in 0..<7 {
            let background = SKSpriteNode(imageNamed: "caveBackground")
            background.size = backgroundSize
            background.texture?.filteringMode = .nearest
            skyBackgrounds.append(background)
        }
        
        for _ in 0..<7 {
            let background = SKSpriteNode(imageNamed: "springDayHighSky")
            background.size = backgroundSize
            background.texture?.filteringMode = .nearest
            highSkyBackgrounds.append(background)
        }
        
        for _ in 0..<13 {
            let background = SKSpriteNode(imageNamed: "springDayLowSky")
            let tileSize = GameConfiguration.worldConfiguration.tileSize
            let width = tileSize.width * 13
            let height = tileSize.height * 13
            background.size = CGSize(width: width, height: height)
            background.texture?.filteringMode = .nearest
            lowSkyBackgrounds.append(background)
        }
        
        GameConfiguration.assemblyManager.createSpriteList(of: skyBackgrounds, at: skyPosition, in: backgroundContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
        
        GameConfiguration.assemblyManager.createSpriteList(of: highSkyBackgrounds, at: highSkyPosition, in: backgroundContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
        
        GameConfiguration.assemblyManager.createSpriteList(of: lowSkyBackgrounds, at: lowSkyPosition, in: backgroundContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: GameConfiguration.worldConfiguration.tileSize,
                        matrix: mapMatrix)
        map.drawTexture("leadSquare")
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
