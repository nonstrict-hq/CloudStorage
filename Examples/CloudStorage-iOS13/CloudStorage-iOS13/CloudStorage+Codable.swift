//
//  CloudStorage+Codable.swift
//  CloudStorage-iOS13
//
//  Created by Tom Lokhorst on 2020-07-18.
//

import Foundation
import CloudStorage

private let sync = CloudStorageSync.shared

extension CloudStorage where Value: Codable {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: {
                guard let data = sync.data(for: key) else { return wrappedValue }
                do {
                    let decoder = PropertyListDecoder()
                    let value = try decoder.decode(Value.self, from: data)
                    return value
                } catch {
                    assertionFailure("\(error)")
                    return wrappedValue
                }
            },
            syncSet: { newValue in
                do {
                    let encoder = PropertyListEncoder()
                    let data = try encoder.encode(newValue)
                    sync.set(data, for: key)
                } catch {
                    assertionFailure("\(error)")
                }
            })
    }
}
