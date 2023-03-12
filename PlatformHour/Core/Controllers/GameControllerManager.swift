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
    
    init(scene: GameScene,
         state: GameState,
         dimension: GameDimension,
         environment: GameEnvironment,
         content: GameContent) {
        self.scene = scene
        self.state = state
        self.environment = environment
        self.content = content
        self.action = ActionLogic(scene: scene , state: state, environment: environment, content: content)
        
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
    var state: GameState
    var environment: GameEnvironment
    var content: GameContent
    var action: ActionLogic
    
    var manager: ControllerManager?
    
    private func setupControllers() {
        manager = ControllerManager(scene: scene)
        setupVirtualController()
        setupControls()
        manager?.observeControllers()
    }
    
    func touch() {
        print("TOUCH")
    }
    
    private func setupControls() {
        manager?.action = ControllerManager.ControllerAction()
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.attack)
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: touch)
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.interactWithStatue)
        manager?.action?.dpad = ControllerManager.DPadAction(left: action.moveLeft,
                                                             right: action.moveRight,
                                                             up: action.upAction,
                                                             down: action.downAction)
    }
    
    private func setupVirtualController() {
        manager?.virtualControllerElements = [.directionPad, .buttonA, .buttonB]
    }
}
