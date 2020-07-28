//
//  WorkspaceViewController.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 16/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit
import WebKit
import SwiftKeychainWrapper

// MARK: - UIViewController

struct ServerResponse: Decodable {
    var results: Int!
    var status: String!
    var users: [String:String]!
}


class WorkspaceViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var userIV: UIImageView!
    
    var userProfile: [String: Any]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        var request = URLRequest(url: URL(string: "http://localhost:3000/api/v1/users")!)
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, _) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if statusCode == 200 {
                
                let rootObject = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
                guard rootObject != nil else { return }
                
                print(rootObject!)
                
                let dataJSON = rootObject?["data"]
                let dataData = try? JSONSerialization.data(withJSONObject: dataJSON!, options: [])
                let dataObject = try? JSONSerialization.jsonObject(with: dataData!, options: []) as? [String: Any]
                
                let usersJSON = dataObject?["users"]
                let usersData = try? JSONSerialization.data(withJSONObject: usersJSON!, options: [])
                let usersObject = try? JSONSerialization.jsonObject(with: usersData!, options: []) as? [Any]
                print(usersObject!)
                
                let dc = try? JSONDecoder().decode([User].self, from: usersData!)
                
                let user = dc![0]
                print(user.email)
            } else {
                print("404")
            }
        }
        task.resume()
    }
    
    // Setting up the UI
    private func setupUI() {
        logoutButton.layer.cornerRadius = 14.0
        logoutButton.layer.borderWidth = 0.75
        logoutButton.layer.borderColor = UIColor.black.cgColor
        
        userProfile = KeychainWrapper.standard.dictionary(forKey: "cache_github_user_profile")
        guard userProfile != nil else { return }
        userIV.image = UIImage(data: try! Data(contentsOf: URL(string: userProfile?["avatar_url"] as! String)!))
        
        let id = userProfile?["id"]
        let email = userProfile?["email"]
        let displayName = userProfile?["display_name"]
        let avatarURL = userProfile?["avatar_url"]
        let accessToken = userProfile?["access_token"]
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        //WebView.shared.deleteCookies()
        if KeychainWrapper.standard.dictionary(forKey: "cache_github_user_profile") != nil {
            KeychainWrapper.standard.removeObject(forKey: "cache_github_user_profile")
        }
    }
}
