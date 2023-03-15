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
    
    init(scene: GameScene) {
        self.scene = scene
        self.action = ActionLogic(scene: scene)
        print("Game Controller initialized ...")
        setupControllers()
    }
    
    enum Button: String, CaseIterable {
        case a
        case b
        
        var image: String {
            switch self {
            case .a: return "buttonA"
            case .b: return "buttonB"
            }
        }
    }
    
    var scene: GameScene
    var action: ActionLogic
    
    var manager: ControllerManager?
    
    private func setupControllers() {
        manager = ControllerManager(scene: scene)
        setupVirtualController()
        setupControls()
        manager?.observeControllers()
    }
    
    private func setupControls() {
        manager?.action = ControllerManager.ControllerAction()
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.attack)
        manager?.action?.buttonB = ControllerManager.ButtonAction()
        manager?.action?.buttonX = ControllerManager.ButtonAction()
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.interact)
        manager?.action?.dpad = ControllerManager.DPadAction(left: action.moveLeft,
                                                             right: action.moveRight,
                                                             up: action.upAction,
                                                             down: action.downAction)
    }
    
    private func setupVirtualController() {
        manager?.virtualControllerElements = [.directionPad, .buttonA, .buttonB, .buttonX, .buttonY]
    }
}
