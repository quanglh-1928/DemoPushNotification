//
//  Utils.swift
//  DemoPushNotification
//
//  Created by ly.hoang.quang on 6/10/19.
//  Copyright © 2019 ly.hoang.quang. All rights reserved.
//

import UIKit

class Utils {
    class func topViewController(controller: UIViewController? = AppDelegate.shared?.window?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
