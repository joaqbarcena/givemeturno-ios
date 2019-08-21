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
    @IBOutlet weak var captchaImage: UIImageView!
    @IBOutlet weak var captchaTextField: UITextField!
    @IBOutlet weak var captchaButton: UIButton!
    
    var infoLogin:[String:String]?
    var userId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = UserDefaults.standard.string(forKey: "userId")
        if userId != nil {
            userIdTextField.text = userId
        }
    }
    
    //MARK: Actions, the only one xd
    
    @IBAction func sendCaptcha(_ sender: UIButton) {
        guard let text = captchaTextField.text,
            !text.isEmpty else {
            self.resultLabel.text = "Captcha vacio"
            return
        }
        guard var infoLogin = infoLogin else {
            self.resultLabel.text = "Info login nulo"
            return
        }
        infoLogin["captcha"] = text
        getUNCReservationAfterCaptcha(userId: userId!, dic:infoLogin){
            alert in
            DispatchQueue.main.async {
                self.resultLabel.text = alert
                self.captchaImage.image = nil
                self.infoLogin = nil
                self.captchaTextField.isEnabled = false
                self.captchaButton.isEnabled = false
            }
        }
    }
    
    @IBAction func getReservation(_ sender: UIButton) {
        if let text = userIdTextField.text {
            if !text.isEmpty {
                userId = text
                UserDefaults.standard.set(userId, forKey: "userId")
                getUNCLogin(userId!, resultCallback: {
                    (info) -> Void in
                    DispatchQueue.main.async {
                        switch(info){
                        case let .ok((dic,data)):
                            guard let data = data, let uma = UIImage(data: data) else {
                                self.resultLabel.text = "Error en la imagen"
                                return
                            }
                            self.captchaImage.image = uma
                            self.infoLogin = dic
                            self.captchaTextField.isEnabled = true
                            self.captchaButton.isEnabled = true
                        case let .fail(err):
                            self.resultLabel.text = err
                        }
                        
                    }
                })
            }
        }
    }
}

