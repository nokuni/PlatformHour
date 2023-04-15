//
//  GameCharacterDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct GameCharacterDialog: Codable {
    init(character: String,
                side: Side,
                lines: [String],
                currentLineIndex: Int = 0,
                isEndOfLine: Bool = false) {
        self.character = character
        self.side = side
        self.lines = lines
        self.currentLineIndex = currentLineIndex
        self.isEndOfLine = isEndOfLine
    }
    
    let character: String?
    let side: Side
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
    
    enum Side: String, Codable {
        case left
        case right
        case none
    }
    
    enum CodingKeys: String, CodingKey {
        case character
        case side
        case lines
    }
}
