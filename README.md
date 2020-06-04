# Local UserNotifications in macOS

`NotificationManager.swift` contains example code for displaying local user notifications on macOS. It's a simplified version of the custom NotificationManager object I use to display notifications in my [GoPro Tracker](https://www.dhurd.com) app. The older, deprecated (and less customizable) way is using `NSUserNotificationCenter`. This is necessary for software running on macOS 10.13 and earlier. In 10.14+, you can use `UNUserNotificationCenter`. It's more customizable, and is also works in iOS, tvOS, watchOS, Mac Catalyst with minor tweaks.

My software has a deployment target of macOS 10.11, so I needed to support both `NSUserNotificationCenter` and `UNUserNotificationCenter`. You'll see the `#available` and `@available` API checks throughout my code.

There's far more functionality in `UNUserNotificationCenter` than what's in my example code. Dig around in the developer documentation for extra goodies!


### Asking user for notification permission

You should ask users for permission to display notifications. This is often done at first launch of the app. Below is an example of asking permission if you are using UNUserNotificationCenter. I put this method in `AppDelegate.swift` and called it from `applicationDidFinishLaunching(_:)`.

~~~
fileprivate func askForNotificationsPermission() {
    if #available(macOS 10.14, *) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
~~~

This code displays a notification asking the user for permission to show notifications with Alerts, Badges, and Sound, as indicated in the `options` array parameter. macOS will create a profile for your app in System Preferences -> Notifications where the user can further modify notification permissions.
