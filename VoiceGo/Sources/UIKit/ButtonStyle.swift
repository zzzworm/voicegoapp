//
//  ButtonStyle.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/28.
//

import SwiftUI

struct HighlightFillButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? Color.black : Color.blue)
      .background(Color.white)
  }

}
