Sample project demonstrating a Core Data stack shared between an app and its Share Extension, using App Groups.

- `URLSession` delegate methods are not properly implemented for background uploads. The app should retrieve transfers as described in [`background(withIdentifier:)`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1407496-background).

- Main app will not automatically reload for Core Data changes from the Share Extension. Consider making use of DarwinNotifications as described in [WWDC 2015 - Session 224](https://developer.apple.com/videos/play/wwdc2015/224/) and below:

```
let darwinNC = CFNotificationCenterGetDarwinNotifyCenter()

CFNotificationCenterAddObserver(darwinNC, nil, { (_, _, _, _, _) in
    // Can't use self here, so use a system notification.
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hello"), object: nil)
}, "APP_MODEL_UPDATED" as CFString, nil, .drop)

NotificationCenter.default.addObserver(forName: NSNotification.Name("hello"), object: nil, queue: OperationQueue.main) { _ in
    self.context.refreshAllObjects()
    print("didUpdateModel or whatever")                                                                                                             }
```

```
let darwinNC = CFNotificationCenterGetDarwinNotifyCenter()

CFNotificationCenterPostNotification(darwinNC, CFNotificationName("APP_MODEL_UPDATED" as CFString), nil, nil, true)
```
