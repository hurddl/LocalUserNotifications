# Local UserNotifications in macOS.

Example code for displaying user notifications on macOS

'''
fileprivate func askForNotificationsPermission() {
    if #available(macOS 10.14, *) {         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
'''
