@CloudStorage property wrapper
==============================

Sync settings through iCloud key-value storage.


## What is this?

Similar to `@AppStorage` and `@SceneStorage` in iOS14, this `@CloudStorage` property wrapper persists values across app restarts.
But this also synchronizes these values across devices using iCloud [Key-Value Storage](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForKey-ValueDataIniCloud.html).

## Usage

### Step 1: Enable the iCloud "Key-value storage" service
1. Select your project file in Xcode, select the target and click "Signing & Capabilities"
2. Hit the "+ Capability" button in the top-left
3. Search for "iCloud" and add the capability
4. Enable the "Key-value storage" service

<details>
<summary>📺 Watch the screen recording of this instruction</summary>
 
![Screen recording](https://user-images.githubusercontent.com/618233/233169058-6b80882e-e0c8-4ec8-82c1-5a789aebbccc.gif)

</details>

### Step 2: Add this library as an SPM dependency

Hit File -> Add Packages... and paste the URL of this GitHub repo to add it to your project.

### Step 3: Use the property wrapper

These values will be synced between devices of the user of your app:
```swift
@CloudStorage("readyForAction") var readyForAction: Bool = false
@CloudStorage("numberOfItems") var numberOfItems: Int = 0
@CloudStorage("orientation") var orientation: String?
``` 

See also the example app in this repository.

## For what should this be used?

The same caveats apply as with key-value storage itself:

> **Key-value storage** is for discrete values such as preferences, settings, and simple app state.
>
> Use iCloud key-value storage for small amounts of data: stocks or weather information, locations, bookmarks, a recent documents list, settings and preferences, and simple game state. Every app submitted to the App Store or Mac App Store should take advantage of key-value storage.

From Apple's documenation on [choosing the proper iCloud Storage API](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW28)

In general, key-value storage is not meant as a general purpose syncing service.
If you need any advanced capabilities to prevent data loss, consider using CloudKit instead.

## Syncing between apps and extensions

To sync the same key-value items between different apps (from the same team) or even between an app and its extensions, follow these steps:

1. Designate one of the apps as the primary app
1. In the other apps/extensions, change the iCloud Key-Value Storage ID manually to be the same as the primary app

For example, if your primary app has the bundle identifier `com.example.my-app`, and its `.entitlements` file has this entry:
```xml
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
```

Make sure in the other apps or extensions to configure the `.entitlements` file like so:
```xml
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>$(TeamIdentifierPrefix)com.example.my-app</string>
```

See also: [Configuring a Common iCloud Container for Multiple Apps (developer.apple.com)](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW26)

## Authors

[Nonstrict B.V.](https://nonstrict.eu), [Tom Lokhorst](https://github.com/tomlokhorst) & [Mathijs Kadijk](https://github.com/mac-cain13), released under [MIT License](LICENSE)

