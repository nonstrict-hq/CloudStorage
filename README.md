@CloudStorage property wrapper
==============================

Sync settings through iCloud key-value storage.


## What is this?

Similar to `@AppStorage` and `@SceneStorage` in iOS14, this `@CloudStorage` property wrapper persists values across app restarts.
But this also synchronizes these values across devices using iCloud [Key-Value Storage](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForKey-ValueDataIniCloud.html).

## Usage

Make sure you enable the "key-value storage" service in the iCloud capability. See [Apple's documentation](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW1)

```swift
@CloudStorage("readyForAction") var readyForAction: Bool = false
@CloudStorage("numberOfItems") var numberOfItems: Int = 0
@CloudStorage("orientation") var orientation: String?
```
In your view add a property

```swift
@ObservedObject var cloudStorageSync = CloudStorageSync.shared
```
to  reveive updated values.

See also the example app in this repository.

## For what should this be used?

The same caveats apply as with key-value storage itself:

> **Key-value storage** is for discrete values such as preferences, settings, and simple app state.
>
> Use iCloud key-value storage for small amounts of data: stocks or weather information, locations, bookmarks, a recent documents list, settings and preferences, and simple game state. Every app submitted to the App Store or Mac App Store should take advantage of key-value storage.

From Apple's documenation on [choosing the proper iCloud Storage API](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW28)

In general, key-value storage is not meant as a general purpose syncing service.
If you need any advanced capabilities to prevent data loss, consider using CloudKit instead.

