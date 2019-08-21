//
//  ReservationService.swift
//  Givemeturno
//
//  Created by Joaquin Barcena on 8/15/19.
//  Copyright © 2019 Joaquin Barcena. All rights reserved.
//

import Foundation

let comedorUrl = "http://comedor.unc.edu.ar/reserva"

// MARK: String Extensions
extension String {
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
    public func findall(pattern: String) -> [String]? {
        let text = self as NSString
        if let regex = try? NSRegularExpression(pattern:pattern) {
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: text.length))
                .map {
                    text.substring(with: $0.range)
            }
        }
        return []
    }
}

// MARK: Main procedure to get reservation

func getUNCLogin(_ userId:String, resultCallback: @escaping (_ info:Result<([String:String],Data?)>)-> Void) -> Void {
    let loginPage = URL(string: comedorUrl)!
    let task = URLSession.shared.dataTask(with: loginPage) {
        (data, response, error) in
        if error == nil && data != nil {
            let loginPageString = String(data: data!, encoding: String.Encoding.isoLatin1)!
            let params = parseWeb(page: loginPageString)
            if let _ = params["path"], let _ = params["token"] {
                //retrieve captcha
                guard let captchaRange = loginPageString.range(of: "/aplicacion\\.php.*?ts=mostrar_captchas_efs.*?>", options: .regularExpression) else {
                    resultCallback(.fail("No se encontro captcha path"))
                    return
                }
                let captchaPath = String(loginPageString[captchaRange].dropLast(4))
                let task = URLSession.shared.dataTask(with: URL(string: comedorUrl + captchaPath)!) {
                    data, res, error in
                    guard error == nil && data != nil else {
                        resultCallback(.fail("No se encontro captcha ... "))
                        return
                    }
                    resultCallback(.ok((params,data)))
                    return
                }
                task.resume()
            } else {
                resultCallback(.fail("Error en el parseo de login"))
            }
        } else {
            resultCallback(.fail("Error en la conexion"))
        }
    }
    task.resume()
}

func getUNCReservationAfterCaptcha(userId:String, dic:[String:String], resultCallback: @escaping (_ info:String) -> Void){
    guard
    let path = dic["path"],
    let token = dic["token"],
    let captcha = dic["captcha"]
    else {
        resultCallback("Info login incompleto")
        return
    }
    let boundary = generateBoundary()
    doAction(userId, path, token, boundary, captcha: captcha) {
        (pag, res, err) in
        if err == nil && pag != nil {
            let accountPageString = String(data: pag!, encoding: String.Encoding.isoLatin1)!
            let params = parseWeb(page: accountPageString)
            if let path = params["path"], let token = params["token"] {
                doAction(userId, path, token, boundary, login:false) {
                    (reg, res, erro) in
                    if erro == nil && reg != nil {
                        let rsvPageString = String(data: reg!, encoding: String.Encoding.isoLatin1)!
                        let params = parseWeb(page: rsvPageString, getAlert: true)
                        if let alert = params["alert"] {
                            resultCallback(alert)
                        } else {
                            resultCallback("Algun error de scrapping hubo")
                        }
                    }else{
                        resultCallback("Error en la reservacion")
                    }
                }
            } else {
                resultCallback("Error en el parseo del account")
            }
        } else {
            resultCallback("Error en el login")
        }
    }
}

private func doAction(_ userId:String,_ path:String,_ token:String,_ boundary:String, captcha:String="",login:Bool=true, callback: @escaping (_ data:Data?, _ response:URLResponse?, _ error:Error?)->Void){
    let loginAction = URL(string: comedorUrl + path)!
    let headers = [
        "cache-control": "no-cache",
        "Content-Type" : "multipart/form-data; boundary=" + boundary
    ]
    let request = NSMutableURLRequest(url: loginAction)
                                      //cachePolicy: .useProtocolCachePolicy,
                                      //timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.httpBody = (login ?
        "--\(boundary)\nContent-Disposition: form-data; name=\"cstoken\"\n\n\(token)\n--\(boundary)\nContent-Disposition: form-data; name=\"form_2689_datos\"\n\n\("ingresar")\n--\(boundary)\nContent-Disposition: form-data; name=\"form_2689_datos_implicito\"\n\n\n--\(boundary)\nContent-Disposition: form-data; name=\"ef_form_2689_datosusuario\"\n\n\(userId)\n--\(boundary)\nContent-Disposition: form-data; name=\"ef_form_2689_datoscontrol\"\n\n\(captcha)\n--\(boundary)--"
         : "--" + boundary + "\nContent-Disposition: form-data; name=\"cstoken\"\n\n" + token + "\n--" + boundary + "\nContent-Disposition: form-data; name=\"ci_2695\"\n\n" + "procesar" + "\n--" + boundary + "\nContent-Disposition: form-data; name=\"ci_2695__param\"\n\n" + "undefined" + "\n--" + boundary + "--"
    ).data(using: String.Encoding.isoLatin1)
    
    let taskLogin = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:callback)
    taskLogin.resume()
}

// MARK : Web parser
private func parseWeb(page:String!, getAlert:Bool=false) -> [String:String] {
    var info:[String:String] = [:]
    let paths = page.findall(pattern: "/aplicacion\\.php.*onsubmit")
    let tokens = page.findall(pattern: "id='cstoken'.*/>")
    if paths != nil && tokens != nil && paths!.count > 0 && tokens!.count > 0 {
        var path = paths![0]
        path = path[0..<(path.count - "' onsubmit".count)]
        var token = tokens![0]
        token = String(token[token.range(of: "value='")!.upperBound..<token.lastIndex(of: "'")!])
        info["path"] = path
        info["token"] = token
    }
    if getAlert {
        //"UD REGISTRA.*;</script></div>"
        if let alerts = page.findall(pattern: "<script language='JavaScript'>alert\\(.*;</script></div>"){
            for alert in alerts {
                if let idxL = alert.range(of: "alert('"),
                    let idxU = alert.range(of: "');") {
                    info["alert"] = String(alert[idxL.upperBound..<idxU.lowerBound])
                    break
                }
            }
        }
    }
    print(info)
    return info
}

private func generateBoundary() -> String {
    return "----WebKitFormBoundary" + .randomString(length: 16)
}
