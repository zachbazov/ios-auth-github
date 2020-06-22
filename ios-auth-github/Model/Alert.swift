//
//  Alert.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 21/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit

let ALERT_TITLE =
"""
"\(Bundle.main.object(forInfoDictionaryKey: "CFBundleName")!)" Wants to Use "github.com" to Sign In
"""

let ALERT_MESSAGE = "This allows the app and website to share information about you."

class Alert: UIAlertController {
    
    enum Provider {
        case github
    }
    
    var target: UIViewController!
    
    var provider: Provider!
   
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(target: UIViewController, provider: Provider) {
        self.init()
        self.provider = provider
        self.target = target
        mode(provider)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func mode(_ provider: Provider) {
        let alert: Alert
        switch provider {
        case .github:
            alert = Alert(title: ALERT_TITLE, message: ALERT_MESSAGE, preferredStyle: .alert)
            
            let dontAllow = UIAlertAction(title: "Don't Allow", style: .default) { _ in
                self.target.dismiss(animated: true, completion: nil)
            }
            
            let allow = UIAlertAction(title: "OK", style: .default) { _ in
                (self.target as! SignViewController).presentWebViewController(provider)
            }
            
            alert.addAction(dontAllow)
            alert.addAction(allow)
        }
        
        target.present(alert, animated: true, completion: nil)
    }
}
