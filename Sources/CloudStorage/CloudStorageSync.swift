//
//  CloudStorageSync.swift
//  CloudStorage
//
//  Created by Tom Lokhorst on 2020-07-05.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

public class CloudStorageSync: ObservableObject {
    public static let shared = CloudStorageSync()

    private let ubiquitousKvs: NSUbiquitousKeyValueStore
    private var publishers: [String: [ObservableObjectPublisher]] = [:]

    @Published private(set) public var status: Status

    private init() {
        ubiquitousKvs = NSUbiquitousKeyValueStore.default
        status = Status(date: Date(), source: .initial, keys: [])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeExternally(notification:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil)
        ubiquitousKvs.synchronize()

        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            ubiquitousKvs,
            selector: #selector(NSUbiquitousKeyValueStore.synchronize),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        #endif
    }

    @objc private func didChangeExternally(notification: Notification) {
        let reasonRaw = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int ?? -1
        let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
        let reason = ChangeReason(rawValue: reasonRaw)

        // Use main queue as synchronization queue to get exclusive accessing to publishers dictionary.
        // Since main queue is needed anyway to change UI properties.
        DispatchQueue.main.async {
            self.status = Status(date: Date(), source: .externalChange(reason), keys: keys)

            for key in keys {
                for publisher in self.publishers[key, default: []] {
                    publisher.send()
                }
            }
        }
    }

    func addObserver(for key: String, publisher: ObservableObjectPublisher) {
        // Use main queue as synchronization queue to get exclusive accessing to publishers dictionary.
        // Since main queue is needed anyway to change UI properties.
        DispatchQueue.main.async {
            self.publishers[key, default: []].append(publisher)
        }
    }

    func removeObserver(publisher: ObservableObjectPublisher) {
        // Use main queue as synchronization queue to get exclusive accessing to publishers dictionary.
        // Since main queue is needed anyway to change UI properties.
        DispatchQueue.main.async {
            self.publishers = self.publishers.mapValues { $0.filter { $0 !== publisher } }
        }
    }

    // Note:
    // As per the documentation of NSUbiquitousKeyValueStore.synchronize,
    // it is not nessesary to call .synchronize all the time.
    //
    // However, during developement, I very often quit or relaunch an app via Xcode debugger.
    // This causes the app to be killed before in-memory changes are persisted to disk.
    //
    // By excessively calling .synchronize() all the time, changes are persisted to disk.
    // This way, when working with Xcode, changes aren't constantly being reverted.
    internal func synchronize() {
        ubiquitousKvs.synchronize()
    }
}

// Wrap calls to NSUbiquitousKeyValueStore
extension CloudStorageSync {
    public func object(forKey key: String) -> Any? {
        ubiquitousKvs.object(forKey: key)
    }

    public func set(_ object: Any?, for key: String) {
        ubiquitousKvs.set(object, forKey: key)
    }

    public func remove(for key: String) {
        ubiquitousKvs.removeObject(forKey: key)
    }

    public func string(for key: String) -> String? {
        ubiquitousKvs.string(forKey: key)
    }

    public func url(for key: String) -> URL? {
        ubiquitousKvs.string(forKey: key).flatMap(URL.init(string:))
    }

    public func array(for key: String) -> [Any]? {
        ubiquitousKvs.array(forKey: key)
    }

    public func dictionary(for key: String) -> [String : Any]? {
        ubiquitousKvs.dictionary(forKey: key)
    }

    public func data(for key: String) -> Data? {
        ubiquitousKvs.data(forKey: key)
    }

    public func int(for key: String) -> Int? {
        if ubiquitousKvs.object(forKey: key) == nil { return nil }
        return Int(ubiquitousKvs.longLong(forKey: key))
    }

    public func int64(for key: String) -> Int64? {
        if ubiquitousKvs.object(forKey: key) == nil { return nil }
        return ubiquitousKvs.longLong(forKey: key)
    }

    public func double(for key: String) -> Double? {
        if ubiquitousKvs.object(forKey: key) == nil { return nil }
        return ubiquitousKvs.double(forKey: key)
    }

    public func bool(for key: String) -> Bool? {
        if ubiquitousKvs.object(forKey: key) == nil { return nil }
        return ubiquitousKvs.bool(forKey: key)
    }


    public func set(_ value: String?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: URL?, for key: String) {
        ubiquitousKvs.set(value?.absoluteString, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: Data?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: [Any]?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: [String : Any]?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: Int?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: Int64?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: Double?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }

    public func set(_ value: Bool?, for key: String) {
        ubiquitousKvs.set(value, forKey: key)
        status = Status(date: Date(), source: .localChange, keys: [key])
    }
}

extension CloudStorageSync {
    public enum ChangeReason {
        case serverChange
        case initialSyncChange
        case quotaViolationChange
        case accountChange

        init?(rawValue: Int) {
            switch rawValue {
            case NSUbiquitousKeyValueStoreServerChange:
                self = .serverChange
            case NSUbiquitousKeyValueStoreInitialSyncChange:
                self = .initialSyncChange
            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                self = .quotaViolationChange
            case NSUbiquitousKeyValueStoreAccountChange:
                self = .accountChange
            default:
                assertionFailure("Unknown NSUbiquitousKeyValueStoreChangeReason \(rawValue)")
                return nil
            }
        }
    }

    public struct Status: CustomStringConvertible {
        public enum Source {
            case initial
            case localChange
            case externalChange(ChangeReason?)
        }

        public var date: Date
        public var source: Source
        public var keys: [String]

        public var description: String {
            let timeString = statusDateFormatter.string(from: date)
            let keysString = keys.joined(separator: ", ")

            switch source {
            case .initial:
                return "[\(timeString)] Initial"

            case .localChange:
                return "[\(timeString)] Local change: \(keysString)"

            case .externalChange(let reason?):
                return "[\(timeString)] External change (\(reason)): \(keysString)"

            case .externalChange(nil):
               return "[\(timeString)] External change (unknown): \(keysString)"
            }
        }
    }
}

private let statusDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    return formatter
}()
