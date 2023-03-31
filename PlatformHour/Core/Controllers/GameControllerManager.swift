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
    var isLongPressingDPad: Bool = false
    var isLongPressingButtonA: Bool = false
    var isLongPressingButtonB: Bool = false
    var isLongPressingButtonX: Bool = false
    var isLongPressingButtonY: Bool = false
    
    private func releaseDPad() {
        isLongPressingDPad = false
    }
    private func releaseButtonA() {
        isLongPressingButtonA = false
    }
    private func releaseButtonB() {
        isLongPressingButtonB = false
    }
    private func releaseButtonX() {
        isLongPressingButtonX = false
    }
    private func releaseButtonY() {
        isLongPressingButtonY = false
    }
    
    public func setupActions() {
        manager?.action = ControllerManager.ControllerAction()
        
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.attack,
                                                                  release: releaseButtonA)
        
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: action.jump,
                                                                  release: releaseButtonB)
        
        manager?.action?.buttonX = ControllerManager.ButtonAction(press: nil,
                                                                  release: releaseButtonX)
        
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.interact,
                                                                  release: releaseButtonY)
        
        manager?.action?.dpad = ControllerManager.DPadAction(leftPress: action.leftPadAction,
                                                             rightPress: action.rightPadAction,
                                                             upPress: action.upPadAction,
                                                             downPress: action.downPadAction,
                                                             release: releaseDPad)
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
