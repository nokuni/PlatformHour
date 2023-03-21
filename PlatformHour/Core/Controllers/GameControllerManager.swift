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
    
    var scene: GameScene
    var action: ActionLogic
    
    var manager: ControllerManager?
    
    public func setupActions() {
        manager?.action = ControllerManager.ControllerAction()
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.attack)
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: action.jump)
        manager?.action?.buttonX = ControllerManager.ButtonAction()
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.interact)
        manager?.action?.dpad = ControllerManager.DPadAction(left: action.leftPadAction,
                                                             right: action.rightPadAction,
                                                             up: action.upPadAction,
                                                             down: action.downPadAction)
    }
    
    private func setupControllers() {
        manager = ControllerManager(scene: scene)
        setupVirtualController()
        setupActions()
        manager?.observeControllers()
    }
    
    private func setupVirtualController() {
        manager?.virtualControllerElements = [.directionPad, .buttonA, .buttonB, .buttonX, .buttonY]
    }
}
