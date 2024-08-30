//
//  CloudStorage+Codable.swift
//
//
//  Created by Tom Lokhorst on 2020-07-18.
//

import SwiftUI
import CloudStorage

@MainActor private let sync = CloudStorageSync.shared

// Extend the CloudStorage property wrapper with support for Codable values.
extension CloudStorage where Value: Codable {
    public init(wrappedValue: Value, _ key: String) {
        func syncGet() -> Value {
            guard let data = sync.data(for: key) else { return wrappedValue }
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                assertionFailure("\(error)")
                return wrappedValue
            }
        }
        func syncSet(_ newValue: Value) {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                sync.set(data, for: key)
            } catch {
                assertionFailure("\(error)")
            }
        }
        self.init(keyName: key, syncGet: syncGet, syncSet: syncSet)
    }
}
