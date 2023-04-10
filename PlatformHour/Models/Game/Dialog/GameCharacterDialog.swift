//
//  GameCharacterDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

public struct GameCharacterDialog: Codable {
    public init(character: String,
                spot: GameCharacterDialog.Spot,
                lines: [String],
                currentLineIndex: Int = 0,
                isEndOfLine: Bool = false) {
        self.character = character
        self.spot = spot
        self.lines = lines
        self.currentLineIndex = currentLineIndex
        self.isEndOfLine = isEndOfLine
    }
    
    public let character: String?
    public let spot: Spot
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
    
    public enum Spot: String, Codable {
        case left
        case right
        case none
    }
    
    enum CodingKeys: String, CodingKey {
        case character
        case spot
        case lines
    }
}
