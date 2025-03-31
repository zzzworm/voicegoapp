import ProjectDescription

let project = Project(
    name: "VoiceGo",
    targets: [
        .target(
            name: "VoiceGo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.zzwormstudio.VoiceGo",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["VoiceGo/Sources/**"],
            resources: [
                "VoiceGo/Resources/**",
            ],
            dependencies: [
                // .external(name: "Maaku"),
                // .external(name: "TexturedMaaku"),
                // .external(name:"TextureSwiftSupport")
                .external(name: "Alamofire"),
                .external(name: "ComposableArchitecture"),
                .external(name: "MarkdownUI"),
                .external(name: "cmark-gfm"),
            ],
            settings: .settings(base: [
            "DEVELOPMENT_ASSET_PATHS": ["VoiceGo/Resources/PreviewContent/Sources", "VoiceGo/Resources/PreviewContent/PreviewAssets.xcassets"] 
            ])
        ),
        // .target(
        //     name: "VoiceGoMac",
        //     destinations: .macOS,
        //     product: .app,
        //     bundleId: "com.zzwormstudio.mac.VoiceGo",
        //     deploymentTargets: .macOS("14.0"),
        //     infoPlist: .extendingDefault(
        //         with: [
        //             "UILaunchScreen": [
        //                 "UIColorName": "",
        //                 "UIImageName": "",
        //             ],
        //         ]
        //     ),
        //     sources: ["VoiceGo/Sources/**"],
        //     resources: [
        //         "VoiceGo/Resources/**",
        //     ],
        //     dependencies: [
        //         // .external(name: "Maaku"),
        //         // .external(name: "TexturedMaaku"),
        //         // .external(name:"TextureSwiftSupport")
        //         .external(name: "Alamofire"),
        //         .external(name: "ComposableArchitecture"),
        //         .external(name: "MarkdownUI"),
        //         .external(name: "cmark-gfm"),
        //     ],
        //     settings: .settings(base: [
        //     "DEVELOPMENT_ASSET_PATHS": ["VoiceGo/Resources/PreviewContent/Sources", "VoiceGo/Resources/PreviewContent/PreviewAssets.xcassets"] 
        //     ])
        // ),
        .target(
            name: "VoiceGoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.zzwormstudio.VoiceGoTests",
            infoPlist: .default,
            sources: ["VoiceGo/Tests/**"],
            resources: [],
            dependencies: [.target(name: "VoiceGo")]
        ),
        // .target(
        //     name: "VoiceGoMacTests",
        //     destinations: .macOS,
        //     product: .unitTests,
        //     bundleId: "com.zzwormstudio.mac.VoiceGoTests",
        //     infoPlist: .default,
        //     sources: ["VoiceGo/Tests/**"],
        //     resources: [],
        //     dependencies: [.target(name: "VoiceGoMac")]
        // ),
    ]
)
