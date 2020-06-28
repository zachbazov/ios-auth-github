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
    
    var webVC: UIViewController!
    
    var nav: UINavigationController!
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    convenience init(target: UIViewController, provider: Provider) {
        self.init()
        self.target = target
        self.provider = provider
        //mode(provider)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    func mode(_ provider: Provider) {
//        switch provider {
//        case .github:
//            // Copycat an web view instance
//            //let webView = AppDelegate.shared.webView
//            // Create a web view controller
//            webVC = UIViewController()
//            // Create a web view
//            navigationDelegate = (target as! SignViewController)
//            // Monitoring page loads
//            addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
//            // Reading a web page’s title as it changes
//            addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
//            // Adding the view to the hierarchy
//            webVC.view.addSubview(self)
//            // Allow using custom constraints
//            translatesAutoresizingMaskIntoConstraints = false
//            // Applying constraints
//            NSLayoutConstraint.activate([
//                topAnchor.constraint(equalTo: webVC.view.topAnchor),
//                leadingAnchor.constraint(equalTo: webVC.view.leadingAnchor),
//                bottomAnchor.constraint(equalTo: webVC.view.bottomAnchor),
//                trailingAnchor.constraint(equalTo: webVC.view.trailingAnchor)
//            ])
//            // Create navigation controller
//            nav = UINavigationController(rootViewController: webVC)
//            // Create done button for navigation
//            let done = UIBarButtonItem(barButtonSystemItem: .done, target: (target as! SignViewController), action: #selector((target as! SignViewController).doneButtonTapped))
//            webVC.navigationItem.leftBarButtonItem = done
//            // Create refresh button for navigationn
//            let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: (target as! SignViewController), action: #selector((target as! SignViewController).refreshButtonTapped))
//            webVC.navigationItem.rightBarButtonItem = refresh
//            // Applying text attributes for title
//            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            nav.navigationBar.titleTextAttributes = attributes
//            // Setting navigation bar style
//            nav.navigationBar.isTranslucent = false
//            nav.navigationBar.tintColor = UIColor.white
//            nav.navigationBar.barTintColor = UIColor.colorFromHex("#333333")
//            // Setting navigation controller view presentation style
//            nav.modalPresentationStyle = UIModalPresentationStyle.popover
//            nav.modalTransitionStyle = .coverVertical
//
//            // Generate random identifier for the authorization
//            let uuid = UUID().uuidString
//            // Create a url request
//            let urlRequest: URLRequest
//            switch provider {
//            case .github:
//                // Setting navigation bar title
//                webVC.navigationItem.title = "github.com"
//                // Complete url scheme for authorization
//                let url = "https://github.com/login/oauth/authorize?client_id=" + GithubConstants.CLIENT_ID + "&scope=" + GithubConstants.SCOPE + "&redirect_uri=" + GithubConstants.REDIRECT_URI + "&state=" + uuid
//                // Making a url request
//                urlRequest = URLRequest(url: URL(string: url)!)
//            case .google:
//                break
//            }
//
//            // Loading the url request by web view
//            load(urlRequest)
//            // Present view controller
//            target.present(nav, animated: true, completion: nil)
//        case .google:
//            break
//        }
//    }
}
