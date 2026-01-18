//
//  SignIn.swift
//  FlexJetting
//
//  Created by Jonathan on 1/18/26.
//

import Foundation

struct SignInRequest: Encodable {
    let username: String
    let password: String
}

struct SignInResponse: Decodable {
    let token: String
}
