//
//  ViewController.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 16/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit
import WebKit

// MARK: - UIViewController

class SignViewController: UIViewController {
    
    @IBOutlet var githubButton: UIButton!
    
    var webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    // Setting up the UI
    private func setupUI() {
        githubButton.layer.cornerRadius = 14.0
        githubButton.layer.borderWidth = 0.75
        githubButton.layer.borderColor = UIColor.black.cgColor
    }
    // Web view configuration, called when a sign method has chosen
    func presentWebViewController() {
        // Create a web view controller
        let webVC = UIViewController()
        // Create a web view
        webView.navigationDelegate = self
        // Monitoring page loads
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        // Reading a web page’s title as it changes
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        // Adding the view to the hierarchy
        webVC.view.addSubview(webView)
        // Allow using custom constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Applying constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webVC.view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webVC.view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: webVC.view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: webVC.view.trailingAnchor)
        ])
        // Generate random identifier for the authorization
        let uuid = UUID().uuidString
        // Complete url scheme for authorization
        let url = "https://github.com/login/oauth/authorize?client_id=" + GithubConstants.CLIENT_ID + "&scope=" + GithubConstants.SCOPE + "&redirect_uri=" + GithubConstants.REDIRECT_URI + "&state=" + uuid
        // Making a url request
        let urlRequest = URLRequest(url: URL(string: url)!)
        // Loading the url request by web view
        webView.load(urlRequest)
        // Create navigation controller
        let nav = UINavigationController(rootViewController: webVC)
        // Create done button for navigation
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        webVC.navigationItem.leftBarButtonItem = done
        // Create refresh button for navigationn
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButtonTapped))
        webVC.navigationItem.rightBarButtonItem = refresh
        // Applying text attributes for title
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        nav.navigationBar.titleTextAttributes = attributes
        // Setting navigation bar title
        webVC.navigationItem.title = "github.com"
        // Setting navigation bar style
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.barTintColor = UIColor.colorFromHex("#333333")
        // Setting navigation controller view presentation style
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        nav.modalTransitionStyle = .coverVertical
        // Present view controller
        self.present(nav, animated: true, completion: nil)
    }
    // Observing operations
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Monitoring page loads
        if keyPath == "estimatedProgress" {
            //print(Float(web.estimatedProgress))
        }
        // Reading a web page’s title as it changes
        if keyPath == "title" {
            if let title = webView.title {
                print(title)
            }
        }
    }
    // Returns to SignViewController from another controller
    @IBAction func unwindToSignVC(segue: UIStoryboardSegue) {}
    // GitHub button action, presenting the web view controller
    @IBAction func githubButtonTapped(_ sender: UIButton) {
        presentWebViewController()
    }
    // Web view's Done button action
    @objc func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    // Web view's Refresh button action
    @objc func refreshButtonTapped() {
        self.webView.reload()
    }
}

// MARK: - WKNavigationDelegate

extension SignViewController: WKNavigationDelegate {
    // Specifying the policy for given url requests whether to allow access or not
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.requestForCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }
    // Get the authorization code string after the '?code=' and before '&state='
    func requestForCallbackURL(request: URLRequest) {
        // Create a request url string
        let requestURLString = (request.url?.absoluteString)! as String
        // Returns a boolean whether the string begins with a specific prefix
        if requestURLString.hasPrefix(GithubConstants.REDIRECT_URI) {
            if requestURLString.contains("code=") {
                // Finds and returns the range of the first occurrence of a given string within a given range of the string
                if let range = requestURLString.range(of: "=") {
                    let code = requestURLString[range.upperBound...]
                    if let range = code.range(of: "&state=") {
                        let authCode = code[..<range.lowerBound]
                        // Request access token
                        githubRequestForAccessToken(authCode: String(authCode))
                        // Close GitHub Auth ViewController after getting Authorization Code
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    // Request access token
    func githubRequestForAccessToken(authCode: String) {
        let grantType = "authorization_code"
        // Set the POST parameters.
        let postParams = "grant_type=" + grantType + "&code=" + authCode + "&client_id=" + GithubConstants.CLIENT_ID + "&client_secret=" + GithubConstants.CLIENT_SECRET
        let postData = postParams.data(using: String.Encoding.utf8)
        let request = NSMutableURLRequest(url: URL(string: GithubConstants.TOKENURL)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, _) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                let results = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
                let accessToken = results?["access_token"] as! String
                // Get user's id, display name, email, profile pic url
                self.fetchGitHubUserProfile(accessToken: accessToken)
            }
        }
        task.resume()
    }
    // Fetch user profile information
    func fetchGitHubUserProfile(accessToken: String) {
        let tokenURL = "https://api.github.com/user"
        let verify: NSURL = NSURL(string: tokenURL)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
        // Setting a header
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil {
                let result = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
                // AccessToken
                print("GitHub Access Token: \(accessToken)")
                // GitHub Id
                let githubId: Int! = (result?["id"] as! Int)
                print("GitHub Id: \(githubId ?? 0)")
                // GitHub Display Name
                let githubDisplayName: String! = (result?["login"] as! String)
                print("GitHub Display Name: \(githubDisplayName ?? "")")
                // GitHub Email
                let githubEmail: String? = (result?["email"] as? String)
                print("GitHub Email: \(githubEmail ?? "")")
                // GitHub Profile Avatar URL
                let githubAvatarURL: String! = (result?["avatar_url"] as! String)
                print("Github Profile Avatar URL: \(githubAvatarURL ?? "")")
                // Perform segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueWorkspace", sender: self)
                }
            }
        }
        task.resume()
    }
}
