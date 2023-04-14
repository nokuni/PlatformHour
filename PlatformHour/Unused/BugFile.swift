//
//  BugFile.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SwiftUI

// MARK: - Disturbance

// When there is multiple inputs at the same time, the actions are added very fastly.

// MARK: Bugs

// 😀
// actions arrows does not display sometimes when in action sequence (inconsistent).

// MARK: - Feedbacks:

// 😀

// MARK: - Improvements

// Click up effect on dialog tap.

// MARK: - Unused Code

//    public func updatePlatformCoordinates() {
//        guard let environment = scene.core?.environment else { return }
//        let platform = environment.map.objects.first { $0.name == "Platform" }
//        guard let platform = platform else { return }
//
//        let element = environment.allElements.first {
//            $0.contains(platform.position)
//        }
//
//        if let tileElement = element as? PKTileNode {
//            platform.coordinate = tileElement.coordinate
//        }
//
//        if let objectElement = element as? PKObjectNode {
//            platform.coordinate = objectElement.coordinate
//        }
//    }

//private func dropDestroyCube(coordinate: Coordinate) {
//    guard let player = scene.player else { return }
//    if let cube = environment.map.objects.first(where: {
//        guard let name = $0.name else { return false }
//        let isCube = name.contains("Cube")
//        let isRightCube = name.extractedNumber == player.currentRoll.rawValue
//        let isRightCoordinate = $0.coordinate == coordinate
//        return isCube && isRightCube && isRightCoordinate
//    }) {
//        instantDestroy(cube)
//    }
//}

//    public func updatePlayerHealth() {
//        guard let dice = scene.player else { return }
//        guard let healthBar = dice.node.childNode(withName: "Health Bar") else { return }
//        healthBar.removeFromParent()
//        scene.core?.content?.addHealthBar(amount: dice.currentBarHealth,
//                                          node: dice.node,
//                                          widthTailoring: (GameConfiguration.worldConfiguration.tileSize.width / 16) * 4)
//    }
