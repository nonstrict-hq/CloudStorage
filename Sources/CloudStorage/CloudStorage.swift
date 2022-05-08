//
//  CloudStorage.swift
//  CloudStorage
//
//  Created by Tom Lokhorst on 2020-07-05.
//

import SwiftUI
import Combine

private let sync = CloudStorageSync.shared

@propertyWrapper public struct CloudStorage<Value>: DynamicProperty {
    private let _setValue: (Value) -> Void

    @ObservedObject private var backingObject: CloudStorageBackingObject<Value>

    public var projectedValue: Binding<Value>

    public var wrappedValue: Value {
        get { backingObject.value }
        nonmutating set { _setValue(newValue) }
    }

    public init(keyName key: String, syncGet: @escaping () -> Value, syncSet: @escaping (Value) -> Void) {
        let value = syncGet()

        let backing = CloudStorageBackingObject(value: value)
        self.backingObject = backing
        self.projectedValue = Binding(
            get: { backing.value },
            set: { [weak holder] newValue in
                backing.value = newValue
                holder?.sender?()
                syncSet(newValue)
                sync.synchronize()
            })
        self._setValue = { [weak holder] (newValue: Value) in
            backing.value = newValue
            holder?.sender?()
            syncSet(newValue)
            sync.synchronize()
        }

        sync.setObserver(for: key) { [weak backing] in
            backing?.value = syncGet()
        }
    }

    class Holder{
        var sender: (() -> Void)?
        init(){}
    }

    var holder = Holder()

    public static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance observed: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> Value {
        get {
            if observed[keyPath: storageKeyPath].holder.sender == nil {
                observed[keyPath: storageKeyPath].holder.sender = { [weak observed] in
                    (observed?.objectWillChange as? ObservableObjectPublisher)?.send()
                }
            }
            return observed[keyPath: storageKeyPath].wrappedValue
        }
        set {
            if let subject = observed.objectWillChange as? ObservableObjectPublisher {
                subject.send()
                observed[keyPath: storageKeyPath].wrappedValue = newValue
            }
        }
    }
}

internal class CloudStorageBackingObject<Value>: ObservableObject {
    @Published var value: Value

    init(value: Value) {
        self.value = value
    }
}

extension CloudStorage where Value == Bool {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.bool(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == Int {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == Double {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.double(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == String {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == URL {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key).flatMap(URL.init(string:)) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue.absoluteString, for: key) })
    }
}

extension CloudStorage where Value == Data {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.data(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value: RawRepresentable, Value.RawValue == Int {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key).flatMap(Value.init) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue.rawValue, for: key) })
    }
}

extension CloudStorage where Value: RawRepresentable, Value.RawValue == String {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key).flatMap(Value.init) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue.rawValue, for: key) })
    }
}

extension CloudStorage where Value == Bool? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.bool(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == Int? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == Double? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.double(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == String? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension CloudStorage where Value == URL? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key).flatMap(URL.init(string:)) },
            syncSet: { newValue in sync.set(newValue?.absoluteString, for: key) })
    }
}

extension CloudStorage where Value == Data? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.data(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}
