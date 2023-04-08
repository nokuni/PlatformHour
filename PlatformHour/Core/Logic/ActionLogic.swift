//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public final class ActionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    public var scene: GameScene
    
    public var timer: Timer?
    public var direction: Direction = .none
    public var movementSpeed: Int = 0
    
    public var isAnimating: Bool {
        guard let player = scene.player else { return false }
        return player.node.hasActions()
    }
    public var isAttacking: Bool {
        scene.isExistingChildNode(named: GameConfiguration.nodeKey.playerProjectile)
    }
    public var canAct: Bool {
        scene.isUserInteractionEnabled
    }
    //private var dialogIndex = 0
    
    // MARK: - Underlying Actions/Animations
    private func addAction(_ action: Player.SequenceAction) {
        guard let player = scene.player else { return }
        guard player.actions.count < player.currentRoll.rawValue else { return }
        player.actions.append(action)
        let actionElement = SKSpriteNode(imageNamed: action.icon)
        actionElement.texture?.filteringMode = .nearest
        actionElement.size = GameConfiguration.worldConfiguration.tileSize * 0.5
        scene.core?.hud?.actionSquares[safe: player.actions.count - 1]?.addChildSafely(actionElement)
        scene.core?.logic?.resolveSequenceOfActions()
    }
    private func move(on direction: Direction, by movementSpeed: Int) {
        guard let player = scene.player else { return }
        guard !isAnimating else { return }
        guard !player.state.isJumping else { return }
        guard canAct else { return }
        
        scene.game?.controller?.isLongPressingDPad = true
        scene.core?.event?.dismissButtonPopUp()
        self.direction = direction
        changeOrientation(direction: self.direction)
        self.movementSpeed = movementSpeed
        moveAnimation(by: self.movementSpeed)
        scene.player?.advanceRoll()
        scene.player?.run()
    }
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
    
    private func moveAnimation(by amount: Int) {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = moveAction(destinationPosition: destinationPosition,
                                      destinationCoordinate: destinationCoordinate, amount: amount)
        
        scene.player?.node.run(moveSequence)
    }
    private func changeOrientation(direction: Direction) {
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
    
    // MARK: - Directional Actions
    
    /// Trigger right pad actions.
    public func rightPadAction() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            moveRight()
        case .inAction:
            addAction(.moveRight)
        case .inDialog:
            break
        }
    }
    
    /// Trigger left pad actions.
    public func leftPadAction() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            moveLeft()
        case .inAction:
            addAction(.moveLeft)
        case .inDialog:
            break
        }
    }
    
    /// Trigger up pad actions.
    public func upPadAction() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            break
        case .inAction:
            addAction(.moveUp)
        case .inDialog:
            break
        }
    }
    
    /// Trigger down pad actions.
    public func downPadAction() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            break
        case .inAction:
            addAction(.moveDown)
        case .inDialog:
            break
        }
    }
    
    private func moveRight() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        let movementSpeed = GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .right, by: movementSpeed)
    }
    private func moveLeft() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        let movementSpeed = -GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .left, by: movementSpeed)
    }
    
    // MARK: - Button Actions
    
    /// Trigger button A actions.
    func actionA() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            jump()
        case .inAction:
            break
        case .inDialog:
            scene.core?.hud?.passDialog()
        }
    }
    
    /// Trigger button B actions.
    func actionB() {
        
    }
    
    /// Trigger button X actions.
    func actionX() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            attack()
        case .inAction:
            break
        case .inDialog:
            break
        }
    }
    
    /// Trigger button Y actions.
    func actionY() {
        guard let player = scene.player else { return }
        
        switch player.controllerState {
        case .normal:
            interact()
        case .inAction:
            break
        case .inDialog:
            break
        }
    }
    
    private func jump() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard player.interactionStatus == .none else { return }
        guard !isAnimating else { return }
        
        let action = jumpAction(player: player)
        
        scene.core?.logic?.disableControls()
        player.state.isJumping = true
        player.node.run(action)
    }
    private func attack() {
        guard !isAttacking else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        if let projectileNode = scene.core?.content?.projectileNode {
            scene.addChild(projectileNode)
            throwProjectile(projectileNode)
        }
    }
    private func interact() {
        guard let player = scene.player else { return }
        guard canAct else { return }
        
        switch player.interactionStatus {
        case .none:
            ()
        case .onExit:
            scene.core?.event?.loadNextLevel()
        }
    }
    
    // MARK: - Miscellaneous
    
    func pause() {
        guard canAct else { return }
        
        switch scene.core?.state.status {
        case .inGame:
            scene.core?.content?.pause()
            scene.core?.state.status = .inPause
            scene.core?.hud?.createPauseScreen()
        case .inPause:
            scene.core?.content?.unpause()
            scene.core?.state.status = .inGame
            scene.core?.hud?.removePauseScreen()
        case .none:
            ()
        }
    }
    
    // MARK: - Animations
    
    func jumpAction(player: Player) -> SKAction {
        let jumpValue = GameConfiguration.playerConfiguration.jumpValue
        let moveUpValue = GameConfiguration.worldConfiguration.tileSize.height
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
            self.scene.core?.animation?.addGravityEffect(on: player.node)
            self.scene.player?.controllerState = .inAction
            self.scene.core?.hud?.addActionSquaresHUD()
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
    func moveAction(destinationPosition: CGPoint,
                    destinationCoordinate: Coordinate,
                    amount: Int) -> SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        let groundCoordinate = Coordinate(x: destinationCoordinate.x + 1, y: destinationCoordinate.y)
        let sequence = SKAction.sequence([
            SKAction.move(to: destinationPosition, duration: player.runDuration),
            endOfMoveAction(groundCoordinate: groundCoordinate)
        ])
        return !environment.collisionCoordinates.contains(destinationCoordinate) ? sequence : SKAction.empty()
    }
    
    private func endOfMoveAction(groundCoordinate: Coordinate) -> SKAction {
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        
        let action = SKAction.run {
            self.scene.core?.sound.step()
            self.scene.player?.node.removeAllActions()
            if !environment.collisionCoordinates.contains(groundCoordinate) {
                self.scene.core?.logic?.dropPlayer()
            }
            self.scene.core?.event?.triggerDialog()
            if self.scene.game!.controller!.isLongPressingDPad {
                self.move(on: self.direction, by: self.movementSpeed)
            }
        }
        
        return action
    }
}
