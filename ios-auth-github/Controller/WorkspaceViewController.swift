//
//  WorkspaceViewController.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 16/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit
import WebKit

// MARK: - UIViewController

class WorkspaceViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        //webView.deleteCookies()
    }
}
