//
//  GameDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation
import Utility_Toolbox

public struct GameDialog: Codable {
    public init(name: String,
                category: GameDialog.Category,
                conversation: [GameCharacterDialog],
                cinematicCompletion: String? = nil,
                currentDialogIndex: Int = 0,
                isEndOfDialog: Bool = false) {
        self.name = name
        self.category = category
        self.conversation = conversation
        self.cinematicCompletion = cinematicCompletion
        self.currentDialogIndex = currentDialogIndex
        self.isEndOfDialog = isEndOfDialog
    }
    
    public let name: String
    public let category: Category
    public var conversation: [GameCharacterDialog]
    public var cinematicCompletion: String?
    public var currentDialogIndex: Int = 0
    public var isEndOfDialog: Bool = false
    
    mutating func moveOnNextDialog() {
        if conversation.canGoNext(currentDialogIndex) {
            currentDialogIndex += 1
        } else {
            isEndOfDialog = true
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
        case conversation
        case cinematicCompletion
    }
}

public extension GameDialog {
    
    static var all: [GameDialog]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.dialogs)
    }
    
    static func get(_ name: String) -> GameDialog? {
        let dialog = GameDialog.all?.first(where: { $0.name == name })
        return dialog
    }
}
