//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import UtilityToolbox

final class ActionLogic {
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    var configuration = ActionLogicConfiguration()
}

// MARK: - DPad Actions

extension ActionLogic {
    
    /// Trigger right pad actions on press.
    func rightPadActionPress() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        configuration.direction = .right
        switch state.status {
        case .inDefault:
            moveRight()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger right pad actions on release.
    func rightPadActionRelease() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveRight)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger left pad actions on press.
    func leftPadActionPress() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        configuration.direction = .left
        switch state.status {
        case .inDefault:
            moveLeft()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger left pad actions on release
    func leftPadActionRelease() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveLeft)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger up pad actions on press.
    func upPadActionPress() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        configuration.direction = .up
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger up pad actions on release.
    func upPadActionRelease() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveUp)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger down pad actions.
    func downPadActionPress() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        configuration.direction = .down
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger down pad actions on release.
    func downPadActionRelease() {
        guard configuration.isEnabled(scene: scene) else { return }
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveDown)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Move the player to the right.
    private func moveRight() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        let movementSpeed = GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .right, by: movementSpeed)
    }
    
    /// Move the player to the left.
    private func moveLeft() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        let movementSpeed = -GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .left, by: movementSpeed)
    }
}

// MARK: - Button Actions

extension ActionLogic {
    
    /// Trigger button A actions.
    func actionA() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            levitate()
        case .inAction:
            break
        case .inConversation:
            scene.core?.hud?.passLine()
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger button B actions.
    func actionB() {
        
    }
    
    /// Trigger button X actions.
    func actionX() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            attack()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger button Y actions.
    func actionY() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            interact()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Release the Dpad.
    func releaseDPad() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            configuration.isLongPressingDPad = false
        case .inAction:
            switch configuration.direction {
            case .none:
                break
            case .up:
                upPadActionRelease()
            case .down:
                downPadActionRelease()
            case .right:
                rightPadActionRelease()
            case .left:
                leftPadActionRelease()
            }
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Levitate.
    private func levitate() {
        guard let player = scene.player else { return }
        guard let game = scene.game else { return }
        guard !player.state.isJumping else { return }
        guard player.interactionStatus == .none else { return }
        guard !player.isAnimating else { return }
        guard game.hasPlayerUnlock(power: .levitate) else { return }
        guard player.energy > 0 else { return }
        
        let action = jumpAction(player: player)
        
        scene.game?.controller?.action.disable()
        player.state.isJumping = true
        player.node.run(action)
    }
    
    /// Attack.
    private func attack() {
        guard let player = scene.player else { return }
        guard !configuration.isAttacking(scene: scene) else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        if let projectileNode = scene.core?.content?.projectileNode {
            scene.addChild(projectileNode)
            throwProjectile(projectileNode)
        }
    }
    
    /// Interact.
    private func interact() {
        guard let player = scene.player else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        switch player.interactionStatus {
        case .none:
            ()
        case .onExit:
            scene.core?.event?.loadNextLevel()
        case .onBlueCrystal:
            scene.core?.event?.activateBlueCrystal()
        }
    }
}

// MARK: - Animations

private extension ActionLogic {
    
    /// Returns the jump animation.
    private func jumpAction(player: Player) -> SKAction {
        let jumpValue = GameConfiguration.playerConfiguration.jumpValue
        let moveUpValue = GameConfiguration.sceneConfiguration.tileSize.height
        let moveUpDestination = CGPoint(x: player.node.position.x,
                                        y: player.node.position.y + moveUpValue)
        let array = stride(from: 0, to: jumpValue, by: 1)
        let destinations = array.map {
            CGPoint(x: moveUpDestination.x, y: moveUpDestination.y + (moveUpValue * $0))
        }
        var actions = destinations.map {
            SKAction.sequence([
                SKAction.move(to: $0, duration: 0.2)
            ])
        }
        
        actions.append(SKAction.run {
            self.scene.core?.animation?.addObjectEffect(keyName: GameConfiguration.nodeKey.sparkEffect,
                                                        scene: self.scene,
                                                        node: player.node,
                                                        timeInterval: 0.1,
                                                        isRepeatingForever: true)
            self.scene.core?.hud?.addActionSquares()
        })
        
        let floatingSequence = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -5, duration: 1),
            SKAction.moveBy(x: 0, y: 5, duration: 1)
        ])
        let floatingAnimation = SKAction.repeatForever(floatingSequence)
        
        actions.append(floatingAnimation)
        
        let jumpSequence = SKAction.sequence(actions)
        
        return jumpSequence
    }
    
    /// Returns the move animation.
    private func moveAction(destinationPosition: CGPoint,
                            destinationCoordinate: Coordinate,
                            amount: Int) -> SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        let groundCoordinate = Coordinate(x: destinationCoordinate.x + 1, y: destinationCoordinate.y)
        let sequence = SKAction.sequence([
            SKAction.move(to: destinationPosition, duration: player.runDuration),
            endOfMoveAction(groundCoordinate: groundCoordinate)
        ])
        let isColliding = environment.collisionCoordinates.contains(destinationCoordinate)
        if !isColliding { player.rollUp() }
        return isColliding ? SKAction.empty() : sequence
    }
    
    /// Returns the end of the move animation.
    private func endOfMoveAction(groundCoordinate: Coordinate) -> SKAction {
        return SKAction.run { [weak self] in
            self?.endOfMoveCompletion(groundCoordinate: groundCoordinate)
        }
    }
    
    /// The completion logic at the end of the movement.
    private func endOfMoveCompletion(groundCoordinate: Coordinate) {
        guard let environment = scene.core?.environment else { return }
        scene.core?.sound.step()
        scene.player?.node.removeAllActions()
        if !environment.collisionCoordinates.contains(groundCoordinate) {
            scene.core?.logic?.dropPlayer()
        }
        scene.core?.event?.triggerConversationOnCoordinate()
        scene.core?.event?.triggerCinematicOnCoordinate()
        scene.core?.logic?.playerDestroy()
        if configuration.isLongPressingDPad {
            move(on: configuration.direction, by: configuration.movementSpeed)
        }
    }
}

// MARK: - Action Sequence

private extension ActionLogic {
    
    /// Adds an action to the action sequence.
    private func addSequenceAction(_ action: PlayerSequenceAction) {
        addPlayerAction(action)
        addActionElement(action)
        scene.core?.logic?.resolveSequenceOfActions()
    }
    
    /// Returns an action element.
    private func actionElement(_ action: PlayerSequenceAction) -> SKSpriteNode {
        let actionElement = SKSpriteNode(imageNamed: action.icon)
        actionElement.texture?.filteringMode = .nearest
        actionElement.zPosition = GameConfiguration.sceneConfiguration.overElementHUDZPosition
        actionElement.size = GameConfiguration.sceneConfiguration.tileSize * 0.6
        return actionElement
    }
    
    /// Adds an action to the action sequence.
    private func addPlayerAction(_ action: PlayerSequenceAction) {
        guard let player = scene.player else { return }
        guard player.actions.count < player.currentRoll.rawValue else { return }
        player.actions.append(action)
    }
    
    /// Adds an action element to the action sequence.
    private func addActionElement(_ action: PlayerSequenceAction) {
        guard let player = scene.player else { return }
        let actionElement = actionElement(action)
        let index = player.actions.count - 1
        let actionSquare = scene.core?.hud?.actionSquares[safe: index]
        let animation = SKAction.sequence([
            SKAction.run { actionSquare?.addChildSafely(actionElement) },
            SKAction.wait(forDuration: GameConfiguration.sceneConfiguration.addActionDelay),
            SKAction.run { [weak self] in
                self?.enable()
            }
        ])
        actionSquare?.run(animation)
    }
}

// MARK: - Underlying Actions/Animations

extension ActionLogic {
    
    /// Moves the player.
    func move(on direction: ActionLogicConfiguration.Direction, by movementSpeed: Int) {
        guard let player = scene.player else { return }
        guard let game = scene.game else { return }
        guard !player.isAnimating else { return }
        guard !player.state.isJumping else { return }
        guard game.hasPlayerUnlock(power: .movement) else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        configuration.isLongPressingDPad = true
        scene.core?.event?.dismissButtonPopUp()
        configuration.direction = direction
        changeOrientation(direction: configuration.direction)
        configuration.movementSpeed = movementSpeed
        moveSequence(by: configuration.movementSpeed)
        player.run()
        player.consumeEnergy(amount: 1)
        scene.core?.hud?.updateEnergy()
    }
    
    /// Throws a projectile.
    private func throwProjectile(_ projectileNode: PKObjectNode) {
        guard let player = scene.player else { return }
        let distanceAmount = CGFloat(player.stats.range)
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        switch player.orientation {
        case .right: xDistance = player.node.size.width * distanceAmount
        case .left: xDistance = -player.node.size.width * distanceAmount
        case .up: yDistance = player.node.size.height * distanceAmount
        case .down: yDistance = -player.node.size.height * distanceAmount
        }
        
        let destination = CGPoint(x: player.node.position.x + xDistance,
                                  y: player.node.position.y + yDistance)
        
        let sequence = SKAction.sequence([
            SKAction.move(to: destination, duration: player.stats.attackSpeed),
            SKAction.run {
                player.state.hasProjectileTurningBack = true
            }
        ])
        
        projectileNode.run(sequence)
    }
    
    /// The player move sequence.
    private func moveSequence(by amount: Int) {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = moveAction(destinationPosition: destinationPosition,
                                      destinationCoordinate: destinationCoordinate, amount: amount)
        
        player.node.run(moveSequence)
    }
    
    /// Changes the player orientation.
    private func changeOrientation(direction: ActionLogicConfiguration.Direction) {
        switch direction {
        case .right:
            scene.player?.orientation = .right
        case .left:
            scene.player?.orientation = .left
        case .up:
            scene.player?.orientation = .up
        case .down:
            scene.player?.orientation = .down
        case .none:
            ()
        }
    }
}

// MARK: - Miscellaneous

extension ActionLogic {
    
    /// Pause the game.
    func pause() {
        guard let state = scene.core?.state else { return }
        scene.core?.content?.pause()
        state.switchOn(newStatus: .inPause)
        scene.core?.hud?.createPauseScreen()
    }
    
    /// Unpause the game.
    func unPause() {
        guard let state = scene.core?.state else { return }
        if state.status == .inPause {
            scene.core?.content?.unpause()
            state.switchOnPreviousStatus()
            scene.core?.hud?.removePauseScreen()
        }
    }
    
    /// Disable actions.
    func disable() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    
    /// Enable actions.
    func enable() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
}
