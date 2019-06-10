//
//  NotificationService.swift
//  RichNotification
//
//  Created by ly.hoang.quang on 6/10/19.
//  Copyright © 2019 ly.hoang.quang. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        func failEarly() {
            if let attemptContent = self.bestAttemptContent {
                contentHandler(attemptContent)
            } else {
                contentHandler(request.content)
            }
        }
        
        guard let content = bestAttemptContent,
            let attachmentUrlStr = content.userInfo["cover_url"] as? String,
            let attachmentUrl = URL(string: attachmentUrlStr),
            let imageData: NSData = NSData(contentsOf: attachmentUrl),
            let attachment = UNNotificationAttachment.create(imageFileIdentifier: "push-thumbnail.png", data: imageData, options: nil) else {
                return failEarly()
        }
        content.attachments = [attachment]
        contentHandler(content.copy() as! UNNotificationContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension UNNotificationAttachment {
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [AnyHashable : Any]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        if fileManager.fileExists(atPath: tmpSubFolderURL.absoluteString) {
            do {
                try fileManager.removeItem(atPath: tmpSubFolderURL.absoluteString)
            } catch { }
        }
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL, options: [])
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        return nil
    }
}
