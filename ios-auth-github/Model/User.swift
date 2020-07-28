//
//  User.swift
//  ios-auth-github
//
//  Created by Zach Bazov on 29/06/2020.
//  Copyright © 2020 Zach Bazov. All rights reserved.
//

import UIKit

struct User: Decodable {

    let __v: Int
    let _id: String
    let email: String
    let name: String
}
