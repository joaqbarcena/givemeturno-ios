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
    var isCookieRestored:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = UserDefaults.standard.string(forKey: "userId")
        if userId != nil {
            userIdTextField.text = userId
        }
        isCookieRestored = restoreCookies()
    }
    
    //MARK: Actions, the only one xd
    @IBAction func cleanCookies(_ sender: UIButton) {
        delCookies()
        isCookieRestored=false
        infoLogin=nil
    }
    
    @IBAction func sendCaptcha(_ sender: UIButton?) {
        var text = ""
        if sender != nil {
            guard let texts = captchaTextField.text,
                !texts.isEmpty else {
                self.resultLabel.text = "Captcha vacio"
                return
            }
            text = texts
        }
        guard var infoLogin = infoLogin else {
            self.resultLabel.text = "Info login nulo"
            return
        }
        infoLogin["captcha"] = text
        getUNCReservationAfterCaptcha(userId: userId!, dic:infoLogin){
            alert in
            DispatchQueue.main.async {
                if alert.range(of: "error", options: .caseInsensitive) == nil &&
                    alert.range(of: "incompleto") == nil {
                    self.storeCookies(and:infoLogin)
                    self.isCookieRestored = true
                } else {
                    self.delCookies()
                    self.isCookieRestored = false
                    self.infoLogin = nil
                }
                self.resultLabel.text = alert
                self.captchaImage.image = nil
                
                self.captchaTextField.isEnabled = false
                self.captchaButton.isEnabled = false
            }
        }
    }
    
    @IBAction func getReservation(_ sender: UIButton) {
        if let text = userIdTextField.text {
            if isCookieRestored {
                sendCaptcha(nil)
                return
            }
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
    
    func storeCookies(and:[String:String]?) {
        let cookiesStorage = HTTPCookieStorage.shared
        let userDefaults = UserDefaults.standard
        
        let serverBaseUrl = "http://comedor.unc.edu.ar"
        var cookieDict = [String : AnyObject]()
        
        for cookie in cookiesStorage.cookies(for: NSURL(string: serverBaseUrl)! as URL)! {
            cookieDict[cookie.name] = cookie.properties as AnyObject?
        }
        
        userDefaults.set(cookieDict, forKey: "cookiesKey")
        userDefaults.set(and, forKey: "info")
    }
    
    func delCookies() {
        UserDefaults.standard.removeObject(forKey: "info")
        UserDefaults.standard.removeObject(forKey: "cookiesKey")
    }
    
    func restoreCookies() -> Bool {
        let cookiesStorage = HTTPCookieStorage.shared
        let userDefaults = UserDefaults.standard
        var res = false
        if let cookieDictionary = userDefaults.dictionary(forKey: "cookiesKey") {
            
            for (_, cookieProperties) in cookieDictionary {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    res = true
                    cookiesStorage.setCookie(cookie)
                }
            }
            
            if let infoL = userDefaults.dictionary(forKey: "info") as?
                [String:String]? {
                infoLogin = infoL
            }
        }
        return res
    }
}

