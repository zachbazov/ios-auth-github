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
    
    var accessToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // Setting up the UI
    private func setupUI() {
        logoutButton.layer.cornerRadius = 14.0
        logoutButton.layer.borderWidth = 0.75
        logoutButton.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        AppDelegate.shared.webView.deleteCookies()
        if KeychainWrapper.standard.string(forKey: "access_token") != nil {
            KeychainWrapper.standard.removeObject(forKey: "access_token")
        }
        accessToken = KeychainWrapper.standard.string(forKey: "access_token")
    }
}
