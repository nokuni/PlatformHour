//
//  GameDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation
import Utility_Toolbox

struct GameDialog: Codable {
    let name: String
    var conversation: [GameCharacterDialog]
    var currentDialogIndex: Int = 0
    var isEndOfDialog: Bool = false
    
    mutating func moveOnNextDialog() {
        if conversation.canGoNext(currentDialogIndex) {
            currentDialogIndex += 1
        } else {
            isEndOfDialog = true
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case conversation
    }
}

extension GameDialog {
    
    static var all: [GameDialog]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonConfigurationKey.dialogs)
    }
    
    static func get(_ name: String) -> GameDialog? {
        let dialog = GameDialog.all?.first(where: { $0.name == name })
        return dialog
    }
}
