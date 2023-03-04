//
//  GameVirtualController.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 03/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameVirtualController {
    
    init(scene: GameScene, dimension: GameDimension, action: ActionLogic) {
        self.scene = scene
        self.dimension = dimension
        self.action = action
    }
    
    public var scene: GameScene
    public var dimension: GameDimension
    public var action: ActionLogic
    
    public var hasPressedAnyInput: Bool = false
    
    private var directionalPadPosition : CGPoint {
        return UIDevice.isOnPhone ?
        CGPoint(x: -CGSize.screen.width * 0.37, y: -CGSize.screen.height * 0.22) :
        CGPoint(x: -CGSize.screen.width * 0.42, y: -CGSize.screen.height * 0.33)
    }
    private var buttonsPosition : CGPoint {
        return UIDevice.isOnPhone ?
        CGPoint(x: CGSize.screen.width * 0.4, y: -CGSize.screen.height * 0.24) :
        CGPoint(x: CGSize.screen.width * 0.45, y: -CGSize.screen.height * 0.35)
    }
    
    private func createDirectionalPadParts(_ padDirections: [ActionLogic.Direction],
                                           _ axes: Axes,
                                           _ image: String,
                                           on position: CGPoint, in node: SKNode) {
        var padNodes: [SKSpriteNode] = []
        
        for pad in padDirections {
            let padNode = SKSpriteNode(imageNamed: image)
            padNode.name = pad.rawValue
            padNode.texture?.filteringMode = .nearest
            padNode.alpha = 0.2
            padNode.size = dimension.tileSize
            padNodes.append(padNode)
        }
        
        dimension.assembly.createSpriteList(of: padNodes, at: position, in: node, axes: axes, alignment: .leading, spacing: 2)
    }
    
    private func createDirectionalPad(on node: SKNode) {
        guard let dimension = scene.dimension else { return }
        
        let directionalPadNode = SKNode()
        directionalPadNode.zPosition = 99
        directionalPadNode.position = directionalPadPosition
        
        node.addChild(directionalPadNode)
        
        createDirectionalPadParts([.left, .right], .horizontal, "horizontalPad", on: CGPoint.zero, in: directionalPadNode)
        
        let verticalPosition = CGPoint(x: dimension.tileSize.width, y: dimension.tileSize.height)
        
        createDirectionalPadParts([.up, .down], .vertical, "verticalPad", on: verticalPosition, in: directionalPadNode)
    }
    private func createButtons(on node: SKNode) {
        guard let dimension = scene.dimension else { return }
        
        let buttonsNode = SKNode()
        buttonsNode.zPosition = 99
        buttonsNode.position = buttonsPosition
        
        node.addChild(buttonsNode)
        
        var buttonNodes: [SKSpriteNode] = []
        
        for button in GameControllerManager.Button.allCases {
            let buttonNode = SKSpriteNode(imageNamed: button.image)
            buttonNode.name = button.rawValue
            buttonNode.texture?.filteringMode = .nearest
            buttonNode.alpha = 0.2
            buttonNode.size = dimension.tileSize
            buttonNodes.append(buttonNode)
        }
        
        dimension.assembly.createSpriteList(of: buttonNodes, at: CGPoint.zero, in: buttonsNode, axes: .horizontal, alignment: .trailing, spacing: 2)
    }
    
    public func create() {
        remove()
        let virtualControllerNode = SKNode()
        virtualControllerNode.name = "Virtual Game Controller"
        scene.camera?.addChild(virtualControllerNode)
        createDirectionalPad(on: virtualControllerNode)
        createButtons(on: virtualControllerNode)
        print("Virtual controller connected ...")
    }
    public func remove() {
        guard let virtualGameController = scene.camera?.childNode(withName: "Virtual Game Controller") else { return }
        print("Virtual controller disconnected ...")
        virtualGameController.removeFromParent()
    }
    
    func touchButton(_ button: GameControllerManager.Button) {
        if !hasPressedAnyInput {
            hasPressedAnyInput = true
            switch button {
            case .a:
                action.jump()
            case .b:
                action.attack()
            }
        }
    }
    func touchDirectionalPad(_ direction: ActionLogic.Direction) {
        if !hasPressedAnyInput {
            hasPressedAnyInput = true
            switch direction {
            case .none: print("Tapped None")
            case .up: print("Tapped Up")
            case .down: print("Tapped Down")
            case .right:
                action.moveRight()
            case .left:
                action.moveLeft()
            }
        }
    }
}
