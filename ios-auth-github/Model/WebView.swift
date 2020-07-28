//
//  Webview.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 23/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit
import WebKit

class WebView: WKWebView {
    
    enum Provider {
        case github
        case google
    }
    
    var target: UIViewController!
    
    var provider: Provider!
    
    var nav: UINavigationController!
    
    static var shared = WebView()
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    convenience init(target: UIViewController, provider: Provider) {
        self.init()
        self.target = target
        self.provider = provider
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func mode(_ provider: Provider) {
        switch provider {
        case .github:
            let webVC = UIViewController()
            navigationDelegate = target as! SignViewController
            webVC.view.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: webVC.view.topAnchor),
                leadingAnchor.constraint(equalTo: webVC.view.leadingAnchor),
                bottomAnchor.constraint(equalTo: webVC.view.bottomAnchor),
                trailingAnchor.constraint(equalTo: webVC.view.trailingAnchor)
            ])
            nav = UINavigationController(rootViewController: webVC)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: (target as! SignViewController), action: #selector((target as! SignViewController).doneButtonTapped))
            webVC.navigationItem.leftBarButtonItem = done
            let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: (target as! SignViewController), action: #selector((target as! SignViewController).refreshButtonTapped))
            webVC.navigationItem.rightBarButtonItem = refresh
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            nav.navigationBar.titleTextAttributes = attributes
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.barTintColor = UIColor.colorFromHex("#333333")
            nav.modalPresentationStyle = UIModalPresentationStyle.popover
            nav.modalTransitionStyle = .coverVertical

            let uuid = UUID().uuidString
            let urlRequest: URLRequest
            switch provider {
            case .github:
                webVC.navigationItem.title = "github.com"
                let url = "https://github.com/login/oauth/authorize?client_id=" + Credential.CLIENT_ID + "&scope=" + Credential.SCOPE + "&redirect_uri=" + Credential.REDIRECT_URI + "&state=" + uuid
                urlRequest = URLRequest(url: URL(string: url)!)
            case .google:
                urlRequest = URLRequest(url: URL(string: "")!)
            }

            load(urlRequest)
            target.present(nav, animated: true, completion: nil)
        case .google:
            break
        }
    }
}
