//
//  AppDelegate.swift
//  DemoPushNotification
//
//  Created by ly.hoang.quang on 6/10/19.
//  Copyright © 2019 ly.hoang.quang. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    static let shared = UIApplication.shared.delegate as? AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupPushNotification()
        return true
    }

    private func setupPushNotification() {
        UNUserNotificationCenter.current().delegate = NotificationHelper.instance
        NotificationHelper.instance.registerPushNotification()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fcmTokenDidRefresh),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    @objc func fcmTokenDidRefresh() {
        print("FCM Token: ---" + (Messaging.messaging().fcmToken ?? ""))
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
}
