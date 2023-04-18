//
//  CloudStorage+Codable.swift
//  CloudStorage-iOS14
//
//  Created by Tom Lokhorst on 2020-07-18.
//

import SwiftUI
import CloudStorage

private let sync = CloudStorageSync.shared

extension CloudStorage where Value: Codable {
    public init(wrappedValue: Value, _ key: String) {
        func syncGet() -> Value {
            guard let data = sync.data(for: key) else { return wrappedValue }
            do {
                let decoder = PropertyListDecoder()
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                assertionFailure("\(error)")
                return wrappedValue
            }
        }
        func syncSet(_ newValue: Value) {
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(newValue)
                sync.set(data, for: key)
            } catch {
                assertionFailure("\(error)")
            }
        }
        self.init(keyName: key, syncGet: syncGet, syncSet: syncSet)
    }
}
