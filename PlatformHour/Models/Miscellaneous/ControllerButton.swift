//
//  ControllerButton.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

public struct ControllerButton: Codable {
    public init(pressedSprite: String,
                releasedSprite: String,
                category: ControllerButton.Category,
                product: ControllerButton.Product) {
        self.pressedSprite = pressedSprite
        self.releasedSprite = releasedSprite
        self.category = category
        self.product = product
    }
    
    
    public let pressedSprite: String
    public let releasedSprite: String
    public let category: Category
    public let product: Product
    
    public enum Category: String, Codable {
        case a
        case b
        case x
        case y
    }
    
    public enum Product: String, Codable {
        case xbox
        case playstation
        case nintendo
    }
}

public extension ControllerButton {
    
    static var all: [ControllerButton]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.controllerButtons)
    }
    
    static func button(_ category: Category, of product: Product) -> [String] {
        let buttons = ControllerButton.all?.first(where: {
            $0.category == category && $0.product == product
        })
        return [buttons?.releasedSprite, buttons?.pressedSprite].compactMap { $0 }
    }
}
