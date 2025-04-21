//
//  LoginEmailRequest.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 08.09.23.
//

struct LoginEmailRequest: Encodable {
    let identifier: String
    let password: String

    
    init(identifier: String, password: String) {
        self.identifier = identifier
        self.password = password
    }
}


struct RegisterEmailRequest: Encodable {
    let email: String
    let username : String
    let password: String

}
