//
//  BundleExtension.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import Foundation

extension Bundle {
    enum BundleError: Error { case wrongURL, noData, wrongData }
    
    // Decode a json file to read his data
    func decode<T: Codable>(_ resource: String) throws -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: nil) else {
            throw BundleError.wrongURL
        }
        guard let data = try? Data(contentsOf: url) else { throw BundleError.noData }
        guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            throw BundleError.wrongData
        }
        return decodedData
    }
}
