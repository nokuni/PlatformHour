//
//  GameCharacterDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct GameCharacterDialog: Codable {
    let character: String
    let spot: Spot
    let lines: [String]
    var currentLineIndex: Int = 0
    var isEndOfLine: Bool = false
    
    mutating func moveOnNextLine() {
        if lines.canGoNext(currentLineIndex) {
            currentLineIndex += 1
        } else {
            isEndOfLine = true
        }
    }
    
    enum Spot: String, Codable {
        case left
        case right
    }
    
    enum CodingKeys: String, CodingKey {
        case character
        case spot
        case lines
    }
}
