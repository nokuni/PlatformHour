//
//  LevelDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

public struct LevelDialog: Codable {
    public init(dialog: String, triggerCoordinate: String) {
        self.dialog = dialog
        self.triggerCoordinate = triggerCoordinate
    }
    
    public let dialog: String
    public let triggerCoordinate: String
    public var isDialogAvailable: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case dialog
        case triggerCoordinate
    }
}
