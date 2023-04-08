//
//  LevelProtocol.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 08/04/23.
//

import Foundation

public protocol LevelProtocol {
    var id: Int { get }
    var name: String { get }
    var coordinate: String { get }
}
