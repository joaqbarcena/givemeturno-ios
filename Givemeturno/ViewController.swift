//
//  ViewController.swift
//  Givemeturno
//
//  Created by Joaquin Barcena on 8/15/19.
//  Copyright © 2019 Joaquin Barcena. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    var userId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = UserDefaults.standard.string(forKey: "userId")
        if userId != nil {
            userIdTextField.text = userId
        }
    }
    
    //MARK: Actions, the only one xd
    
    @IBAction func getReservation(_ sender: UIButton) {
        if let text = userIdTextField.text {
            if !text.isEmpty {
                userId = text
                UserDefaults.standard.set(userId, forKey: "userId")
                getUNCReservation(userId!, resultCallback: {
                    (alert) -> Void in
                    DispatchQueue.main.async {
                        self.resultLabel.text = alert
                    }
                })
            }
        }
    }
}

