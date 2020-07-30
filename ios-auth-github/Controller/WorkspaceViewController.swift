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

class WorkspaceViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var userIV: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    
    var userProfile: [String: Any]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // Setting up the UI
    private func setupUI() {
        logoutButton.layer.cornerRadius = 14.0
        logoutButton.layer.borderWidth = 0.75
        logoutButton.layer.borderColor = UIColor.black.cgColor
        
        userProfile = KeychainWrapper.standard.dictionary(forKey: "cache_github_user_profile")
        guard userProfile != nil else { return }
        userIV.image = UIImage(data: try! Data(contentsOf: URL(string: userProfile?["avatar_url"] as! String)!))
        
        let id = self.userProfile?["id"] as! Int
        let email = self.userProfile?["email"] as! String
        let displayName = self.userProfile?["display_name"] as! String
        let avatarURL = self.userProfile?["avatar_url"] as! String
        let accessToken = self.userProfile?["access_token"] as! String
        
        self.idLabel.text = String(id)
        self.nameLabel.text = displayName
        self.emailLabel.text = email
        self.tokenLabel.text = accessToken
        self.avatarLabel.text = avatarURL
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        WebView.shared.deleteCookies()
        if KeychainWrapper.standard.dictionary(forKey: "cache_github_user_profile") != nil {
            KeychainWrapper.standard.removeObject(forKey: "cache_github_user_profile")
        }
    }
}
