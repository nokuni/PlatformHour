//
//  GameCharacterDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

public struct GameCharacterDialog: Codable {
    public init(character: String,
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
    
    public let character: String?
    public let side: Side
    public let lines: [String]
    public var currentLineIndex: Int = 0
    public var isEndOfLine: Bool = false
    
    mutating func moveOnNextLine() {
        if lines.canGoNext(currentLineIndex) {
            currentLineIndex += 1
        } else {
            isEndOfLine = true
        }
    }
    
    public enum Side: String, Codable {
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
