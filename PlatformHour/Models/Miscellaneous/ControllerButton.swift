//
//  ControllerButton.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

struct ControllerButton: Codable {
    let pressedSprite: String
    let releasedSprite: String
    let category: Category
    let product: Product

    enum Category: String, Codable {
        case a
        case b
        case x
        case y
    }
    enum Product: String, Codable {
        case xbox
        case playstation
        case nintendo
    }
}

extension ControllerButton {
    
    static var all: [ControllerButton]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonConfigurationKey.controllerButtons)
    }
    
    static func button(_ category: Category, of product: Product) -> [String] {
        let buttons = ControllerButton.all?.first(where: {
            $0.category == category && $0.product == product
        })
        return [buttons?.releasedSprite, buttons?.pressedSprite].compactMap { $0 }
    }
}
