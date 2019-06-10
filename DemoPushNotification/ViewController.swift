//
//  ViewController.swift
//  DemoPushNotification
//
//  Created by ly.hoang.quang on 6/10/19.
//  Copyright © 2019 ly.hoang.quang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    var screenCodeFromNotification: Int = 0 {
        didSet {
            switch screenCodeFromNotification {
            case 1:
                performSegue(withIdentifier: "goTo1", sender: nil)
            case 2:
                performSegue(withIdentifier: "goTo2", sender: nil)
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func pushLocalNotification(_ sender: Any) {
        guard let message = messageTextField.text, let time = Double(timeTextField.text ?? "0") else { return }
        messageTextField.resignFirstResponder()
        timeTextField.resignFirstResponder()
        NotificationHelper.setupLocalNotification(after: time, message: message)
    }
    
}

