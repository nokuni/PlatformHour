//
//  GameControllerManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit

final public class GameControllerManager {
    
    public init(scene: GameScene, state: GameState) {
        self.scene = scene
        self.state = state
        self.action = ActionLogic(scene: scene, state: state)
        print("Game Controller initialized ...")
        setupControllers()
    }
    
    public var scene: GameScene
    public var state: GameState
    public var action: ActionLogic
    
    public var manager: ControllerManager?
}

// MARK: - Setups

public extension GameControllerManager {
    
    /// Setup the actions on the gamepad controller
    func setupActions() {
        manager?.action = ControllerManager.ControllerAction()
        
        // Cross
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.actionA,
                                                                  release: nil)
        
        // Circle
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: action.actionB,
                                                                  release: nil)
        
        // Square
        manager?.action?.buttonX = ControllerManager.ButtonAction(press: action.actionX,
                                                                  release: nil)
        
        // Triangle
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.actionY,
                                                                  release: nil)
        
        manager?.action?.dpad = ControllerManager.DPadAction(leftPress: action.leftPadAction,
                                                             rightPress: action.rightPadAction,
                                                             upPress: action.upPadAction,
                                                             downPress: action.downPadAction,
                                                             release: action.releaseDPad)
    }
    
    /// Setup the controllers
    private func setupControllers() {
        manager = ControllerManager(scene: scene)
        setupVirtualController()
        setupActions()
        manager?.observeControllers()
    }
    
    /// Setup the virtual controller.
    private func setupVirtualController() {
        manager?.virtualControllerElements = [.directionPad, .buttonA, .buttonB, .buttonX, .buttonY]
    }
}

// MARK: - Actions

public extension GameControllerManager {
    
    /// Hide buttons from virtual controller.
    func hideVirtualController() {
        manager?.disconnectVirtualController()
        manager?.virtualControllerElements = []
        manager?.connectVirtualController()
    }
}
