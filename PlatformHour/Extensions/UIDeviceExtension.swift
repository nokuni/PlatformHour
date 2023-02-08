//
//  UIDeviceExtension.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 03/02/23.
//

import UIKit

extension UIDevice {
    static let isOnPhone = UIDevice.current.userInterfaceIdiom == .phone
    static let isOnPad = UIDevice.current.userInterfaceIdiom == .pad
}
