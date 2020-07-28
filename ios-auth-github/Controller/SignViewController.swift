//
//  ViewController.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 16/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit
import WebKit
import SwiftKeychainWrapper

// MARK: - UIViewController

class SignViewController: UIViewController {
    
    @IBOutlet var githubButton: UIButton!
    
    var userProfile = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainWrapper.standard.dictionary(forKey: "cache_github_user_profile") != nil {
            let vc = storyboard?.instantiateViewController(identifier: "workspaceViewController")
            vc?.modalPresentationStyle = .fullScreen
            present(vc!, animated: false, completion: nil)
        }
    }
    
    private func setupUI() {
        githubButton.layer.cornerRadius = 14.0
        githubButton.layer.borderWidth = 0.75
        githubButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func presentWebViewController(_ provider: Alert.Provider) {
        WebView(target: self, provider: .github).mode(.github)
    }
    
    @IBAction func unwindToSignVC(segue: UIStoryboardSegue) {}
    
    @IBAction func githubButtonTapped(_ sender: UIButton) {
        Alert(target: self, provider: .github).present()
    }
    
    @objc func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshButtonTapped() {
        WebView.shared.reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueWorkspace" {
            KeychainWrapper.standard.set(userProfile, forKey: "cache_github_user_profile")
        }
    }
}

// MARK: - WKWebView

extension WebView {
    
    func deleteCookies() {
        let cookieStore = configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                cookieStore.delete(cookie)
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension SignViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.requestCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }
}

// MARK: - GitHub API

extension SignViewController {
    
    func requestCallbackURL(request: URLRequest) {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(Credential.REDIRECT_URI) {
            if requestURLString.contains("code=") {
                if let range = requestURLString.range(of: "=") {
                    let code = requestURLString[range.upperBound...]
                    if let range = code.range(of: "&state=") {
                        let authCode = code[..<range.lowerBound]
                        requestAccessToken(authCode: String(authCode))
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func requestAccessToken(authCode: String) {
        let grantType = "authorization_code"
        let postParams = "grant_type=" + grantType + "&code=" + authCode + "&client_id=" + Credential.CLIENT_ID + "&client_secret=" + Credential.CLIENT_SECRET
        let postData = postParams.data(using: String.Encoding.utf8)
        let request = NSMutableURLRequest(url: URL(string: Credential.TOKENURL)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, _) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200 {
                let results = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
                let accessToken = results?["access_token"] as? String
                self.requestUserProfile(accessToken: accessToken ?? "")
            }
        }
        task.resume()
    }
    
    func requestUserProfile(accessToken: String) {
        let tokenURL = "https://api.github.com/user"
        let verify: NSURL = NSURL(string: tokenURL)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil {
                let result = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
                let id: Int! = (result?["id"] as! Int)
                let displayName: String! = (result?["login"] as! String)
                let email: String? = (result?["email"] as? String)
                let avatarURL: String! = (result?["avatar_url"] as! String)
                self.userProfile["id"] = id
                self.userProfile["display_name"] = displayName
                self.userProfile["email"] = email
                self.userProfile["avatar_url"] = avatarURL
                self.userProfile["access_token"] = accessToken
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueWorkspace", sender: self)
                }
            }
        }
        task.resume()
    }
}

// MARK: - KeychainWrapper

extension KeychainWrapper {
    
    func set(_ value: [String: Any], forKey key: String) {
        do {
            try set(NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false), forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }

    func dictionary(forKey key: String) -> [String: Any]? {
        if let storedData = self.data(forKey: key) {
            do {
                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? [String : Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
