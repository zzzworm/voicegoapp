//
//  MarkdownTheme.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/27.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//
import MarkdownUI

extension Theme {
  static let fancy = Theme()
    .code {
      FontFamilyVariant(.monospaced)
      FontSize(.em(0.85))
    }
    .link {
      ForegroundColor(.purple)
    }
    // More text styles...
    .paragraph { configuration in
      configuration.label
            .relativeLineSpacing(.em(0.0))
            .relativePadding(.leading, length: .em(0.5))
        .markdownMargin(top: 0, bottom: 6)
    }
    .blockquote { configuration in
      configuration.label
            .relativeLineSpacing(.em(0.0))
            .relativePadding(.leading, length: .em(0.5))
        .markdownMargin(top: 0, bottom: 6)
    }
    .list {
      configuration in
      configuration.label
            .relativeLineSpacing(.em(0.0))
            .relativePadding(.leading, length: .em(0.5))
        .markdownMargin(top: 0, bottom: 6)
    }
    .listItem { configuration in
      configuration.label
            .relativeLineSpacing(.em(0.0))
            .relativePadding(.leading, length: .em(0.5))
        .markdownMargin(top: .em(0.25))
    }
}
