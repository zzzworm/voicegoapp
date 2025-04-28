//
//  AppTextFieldStyle.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 8)
            .foregroundColor(.darkText)
        
            Rectangle()
            .frame(height: 0.5)
            .foregroundColor(.systemBackground)
    }
}

extension TextFieldStyle where Self == AppTextFieldStyle {
    static var main: AppTextFieldStyle { .init() }
}
