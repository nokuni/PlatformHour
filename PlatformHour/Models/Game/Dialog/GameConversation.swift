//
//  GameDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation
import Utility_Toolbox

public struct GameConversation: Codable {
    public init(name: String,
                category: GameConversation.Category,
                dialogs: [GameCharacterDialog],
                cinematicCompletion: String? = nil,
                currentDialogIndex: Int = 0,
                isEndOfConversation: Bool = false) {
        self.name = name
        self.category = category
        self.dialogs = dialogs
        self.cinematicCompletion = cinematicCompletion
        self.currentDialogIndex = currentDialogIndex
        self.isEndOfConversation = isEndOfConversation
    }
    
    public let name: String
    public let category: Category
    public var dialogs: [GameCharacterDialog]
    public var cinematicCompletion: String?
    public var currentDialogIndex: Int = 0
    public var isEndOfConversation: Bool = false
    
    mutating func moveOnNextDialog() {
        if dialogs.canGoNext(currentDialogIndex) {
            currentDialogIndex += 1
        } else {
            isEndOfConversation = true
        }
    }
    
    public enum Category: String, Codable {
        case onLevelStart
        case onNodeAlteration
        case onPlayerCoordinate
        case onCinematic
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case dialogs
        case cinematicCompletion
    }
}

public extension GameConversation {
    
    /// Returns all the conversations of the game
    static var all: [GameConversation]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.conversations)
    }
    
    static func get(_ name: String) -> GameConversation? {
        let dialog = GameConversation.all?.first(where: { $0.name == name })
        return dialog
    }
}
