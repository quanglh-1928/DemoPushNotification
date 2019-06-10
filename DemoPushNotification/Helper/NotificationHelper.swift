//
//  NotificationHelper.swift
//  DemoPushNotification
//
//  Created by ly.hoang.quang on 6/10/19.
//  Copyright © 2019 ly.hoang.quang. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyJSON

class NotificationHelper: NSObject {
    
    // MARK: - Singleton
    static var instance = NotificationHelper()
    
    // Cache push notification data to show (when app is killed or not being opened)
    var launchRemoteData: [AnyHashable : Any]?
    
    // MARK: - Register push notification
    func registerPushNotification(application: UIApplication = UIApplication.shared, completion: ((Bool) -> Void)? = nil) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { granted, error in
            DispatchQueue.main.async {
                if error == nil && granted {
                    application.registerForRemoteNotifications()
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        })
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Supporting methods
    func getDeliveredNotificationsCount(completion: @escaping ((_ count: Int) -> Void)) {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (notifications) in
            DispatchQueue.main.async {
                completion(notifications.count)
            }
        })
    }
    
    func removeAllLocalNotifications(removeDelivered: Bool = false, completion: @escaping (() -> Void)) {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                DispatchQueue.main.async {
                    let removeIds = requests.map({ $0.identifier })
                    center.removePendingNotificationRequests(withIdentifiers: removeIds)
                    print("[Local Notification] Removed all ! (iOS >= 10)")
                    completion()
                }
            })
            if removeDelivered {
                center.getDeliveredNotifications(completionHandler: { notifications in
                    DispatchQueue.main.async {
                        let removeIds = notifications.map { $0.request.identifier }
                        center.removeDeliveredNotifications(withIdentifiers: removeIds)
                    }
                })
            }
        } else {
            if let localNotis = application.scheduledLocalNotifications {
                localNotis.forEach {
                    application.cancelLocalNotification($0)
                }
                print("[Local Notification] Removed all ! (iOS < 10)")
            }
            completion()
        }
    }
    
    func removeLocalNotificationsWith(identifier: String,
                                      removeDelivered: Bool = false,
                                      completion: @escaping (() -> Void)) {
        let application = UIApplication.shared
        let identifierKey = "Identifier"
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            func removeDeliveredIfNeeded() {
                if removeDelivered {
                    center.getDeliveredNotifications(completionHandler: { notifications in
                        DispatchQueue.main.async {
                            var removeIds = [String]()
                            for noti in notifications {
                                let request = noti.request
                                if let id = request.content.userInfo[identifierKey] as? String, id == identifier {
                                    removeIds.append(request.identifier)
                                }
                            }
                            center.removeDeliveredNotifications(withIdentifiers: removeIds)
                            completion()
                        }
                    })
                } else { completion() }
            }
            center.getPendingNotificationRequests(completionHandler: { requests in
                DispatchQueue.main.async {
                    let removeIds = requests.filter({
                        if let id = $0.content.userInfo[identifierKey] as? String {
                            return id == identifier
                        }
                        return false
                    }).map({ $0.identifier })
                    center.removePendingNotificationRequests(withIdentifiers: removeIds)
                    print("[Local Notification][Type: \(identifier)] Removed all ! (iOS >= 10)")
                    if removeDelivered { removeDeliveredIfNeeded() }
                    else { completion() }
                }
            })
        } else {
            if let localNotifications = application.scheduledLocalNotifications {
                let targetList = localNotifications.filter({
                    if let id = $0.userInfo?[identifierKey] as? String {
                        return id == identifier
                    }
                    return false
                })
                targetList.forEach {
                    application.cancelLocalNotification($0)
                }
                print("[Local Notification][Type: \(identifier)] Removed all ! (iOS < 10)")
            }
            completion()
        }
    }
}

// MARK: - Handle push notification & local notification data
extension NotificationHelper {
    // MARK: - Receive data from remote & local notifications
    func received(notification userInfo: [AnyHashable: Any]) {
        // Write your code
        let json = JSON(userInfo)
        navigateNotiToApp(json: json)
    }
}

extension NotificationHelper: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        received(notification: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let jsonData = JSON(notification.request.content.userInfo)
        print("[USER NOTIFICATION CENTER] - Received response:\n\(jsonData)\n")
        // TODO: Check if you need to show notification alert or not by calling completionHandler
        completionHandler([.alert, .badge, .sound])
    }
    
    private func navigateNotiToApp(json: JSON) {
        if let screenCode = Int(json["screen_code"].stringValue), let vc = Utils.topViewController() as? ViewController {
            vc.screenCodeFromNotification = screenCode
        }
    }
}

extension NotificationHelper {
    static func setupLocalNotification(after second: Double, message: String = "", sound: UNNotificationSound = .default) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let date = Date().addingTimeInterval(second)
        content.body = message
        content.title = "Test local notification"
        content.sound = sound
        let triggerDate = Calendar.current.dateComponents([ .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        let request = UNNotificationRequest(identifier: "local.notification",
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}
