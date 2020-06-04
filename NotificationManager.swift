//
//  NotificationManager.swift
//  
//
//  Created by David Hurd on 6/3/20.
//

import Cocoa
import UserNotifications

class NotificationManager: NSObject {
    
    // Make sure you ask user for notification permissions in your AppDelegate!
    
    // MARK: - Setup
    
    override init() {
        super.init()
        
        // Delegate implementation is broken out into class extensions at the end of this file
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
            NSUserNotificationCenter.default.delegate = self
        }
    }
    
    
    // MARK: - Public Functions
    
    func showInteractiveNotification(for object: Any) {
        // Use UNUserNotification for macOS 10.14+, otherwise use depricated NSUserNotification
        if #available(macOS 10.14, *) {
            self.showInteractiveUNUserNotification(for: object)
        } else {
            self.showInteractiveNSUserNotification(for: object)
        }
    }
    
    func showBasicNotification(for object: Any) {
        // Use UNUserNotification for macOS 10.14+, otherwise use depricated NSUserNotification
        if #available(macOS 10.14, *) {
            self.showBasicUNUserNotification(for: object)
        } else {
            self.showBasicNSUserNotification(for: object)
        }
    }
    
    
    // MARK: - Private macOS Version Helpers

    // this is a text input notification using NSUserNotificationCenter
    fileprivate func showInteractiveNSUserNotification(for object: Any) {
        // build the notification
        let notification = NSUserNotification()
        
        // you can use information from the object parameter to create more robust content
        
        // pass any information or objects you need the delegate to receive in userInfo
        notification.userInfo = ["Example key": "Example value", "Another key": "Another value"]
        
        notification.title = "This is the Title"
        notification.informativeText = "This is the informative text."
        
        notification.hasReplyButton = true
        notification.responsePlaceholder = "This is where you type a reply"
        
        // ask macOS to deliver the notification
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    // this is a basic notification using deprecated NSUserNotificationCenter
    fileprivate func showBasicNSUserNotification(for object: Any) {
        // build the notification
        // you can use information from the object parameter to create more robust content
        let notification = NSUserNotification()
        notification.hasActionButton = false // no extra buttons on this notification
        notification.title = "This is the Title"
        notification.subtitle = "This is the subtitle."
        notification.informativeText = "This is the informative text."
        
        // ask macOS to deliver the notification
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    
    // this is a text input custom notification using UNUserNotificationCenter
    @available(macOS 10.14, *)
    fileprivate func showInteractiveUNUserNotification(for object: Any) {
        
        // build notification text input action button
        let customAction = UNTextInputNotificationAction(identifier: "customAction", title: "Click me!", options: .foreground, textInputButtonTitle: "Do it!", textInputPlaceholder: "Enter your text here")
        
        // assign our customAction to a category object
        let category = UNNotificationCategory(identifier: "exampleCategory", actions: [customAction], intentIdentifiers: [])
        
        // register the category with UNUserNotificationCenter
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // build notification content
        // you can use information from the object parameter to create more robust content
        let content = UNMutableNotificationContent()
        content.userInfo = ["Example key": "Example value", "Another key": "Another value"]
        content.title = "This is the Title"
        content.subtitle = "This is the subtitle."
        content.sound = UNNotificationSound.default
        
        // assign our previously created category to be used by this notification
        content.categoryIdentifier = "exampleCategory"

        // build and add notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // this is a basic notification using UNUserNotificationCenter
    @available(macOS 10.14, *)
    fileprivate func showBasicUNUserNotification(for object: Any) {

        // you can use information from the object parameter to create more robust content
        let content = UNMutableNotificationContent()
        content.title = "This is the Title"
        content.subtitle = "This is the subtitle."
        content.body = "This is the body."
        content.sound = UNNotificationSound.default
        
        // build and add notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}


// MARK: - NSUserNotificationCenterDelegate

extension NotificationManager: NSUserNotificationCenterDelegate {
    
    // you can use this method to turn off notifications if the user doesn't want them
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    // this method is called when our NSUserNotification action button is clicked
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) { // switch on whether user clicked "reply" or "cancel"
        case .replied:
            guard let res = notification.response else { return }
            // do something with the reply text here
            print(res)
            
            // you can also access anything from your userInfo dictionary
            guard let info = notification.userInfo?["Example key"] else { return }
            print(info)
        default:
            break
        }
    }
}


// MARK: - UNUserNotificationCenterDelegate

@available(macOS 10.14, *)
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    // this method is called when a button in our UNUserNotification is clicked
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary (if needed)
        let userInfo = response.notification.request.content.userInfo
            
        if response.actionIdentifier == "customAction" { // this is the identifier we assigned to our action button earlier
            guard let textResponse = response as? UNTextInputNotificationResponse else { return }
            
            // do some work with the response here
            print(textResponse.userText)
        }
        // you must call the completion handler when you're done
        completionHandler()
    }
}

