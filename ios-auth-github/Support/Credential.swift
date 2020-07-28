//
//  Constant.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 16/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit

struct Credential {

    static let CLIENT_ID = "85a06088ff1e98509316"
    static let CLIENT_SECRET = "2ebc0128f4534d0e27b1febb06141c0382ab93e1"
    static let REDIRECT_URI = "https://divingfirebase.firebaseapp.com/__/auth/handler"
    static let SCOPE = "read:user,user:email"
    static let TOKENURL = "https://github.com/login/oauth/access_token"
}
