//
//  StringExtension.swift
//  ProjectA
//
//  Created by Maertens Yann-Christophe on 25/01/23.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String {
    var extractedNumber: Int? {
        return Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
