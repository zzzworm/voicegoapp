//
//  LoginEmailRequest.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 08.09.23.
//

struct LoginEmailRequest: Encodable {
    let identifier: String
    let password: String
}

struct RegisterEmailRequest: Encodable {
    let email: String
    let username: String
    let password: String

}
