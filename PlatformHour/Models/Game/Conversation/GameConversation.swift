//
//  GameDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation
import UtilityToolbox

struct GameConversation: Codable {
    let name: String
    let category: Category
    var dialogs: [GameDialog]
    var cinematicCompletion: String?
    var currentDialogIndex: Int = 0
    var isEndOfConversation: Bool = false
    
    mutating func moveOnNextDialog() {
        if dialogs.canGoNext(from: currentDialogIndex) {
            currentDialogIndex += 1
        } else {
            isEndOfConversation = true
        }
    }
    
    enum Category: String, Codable {
        case onLevelStart
        case onObject
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

extension GameConversation {
    
    /// Returns all the conversations of the game
    static var all: [GameConversation]? {
        try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.conversations)
    }
    
    static func get(_ name: String) -> GameConversation? {
        let dialog = GameConversation.all?.first(where: { $0.name == name })
        return dialog
    }
}
