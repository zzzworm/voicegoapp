import ProjectDescription

let project = Project(
    name: "VoiceGo",
    organizationName: "Shanghai Souler Information Technology Co., Ltd.",
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
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true,
                        "NSAllowsLocalNetworking": true,
                    ],
                    "NSPhotoLibraryUsageDescription": "App需要访问您的照片库，以便您可以选择图片进行处理。",
                    "NSMicrophoneUsageDescription": "App需要访问您的麦克风，以便您可以进行语音输入。",
                    "NSCameraUsageDescription": "App需要访问您的相机，以便您可以拍摄照片或视频。",
                    "NSPhotoLibraryAddUsageDescription": "App需要访问您的照片库，以便您可以保存图片。",
                    "NSSpeechRecognitionUsageDescription": "App需要访问您的语音识别功能，以便您可以进行语音输入。",
                    "NSLocalNetworkUsageDescription": "App需要访问您的本地网络，以便您可以使用局域网功能。",
                    "NSBonjourServices" : [
                        "_pulse._tcp",
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
                .external(name: "Moya"),
                .external(name: "Pulse"),
                .external(name: "PulseUI"),
                .external(name: "SwiftyJSON"),
                .external(name: "FSRS"),
                .external(name: "Nuke"),
                .external(name: "NukeUI"),
                .external(name: "AliyunOSSSDK"),
            ],
            settings: .settings(base: [
            "DEVELOPMENT_ASSET_PATHS": ["VoiceGo/Resources/PreviewContent/Sources", "VoiceGo/Resources/PreviewContent/PreviewAssets.xcassets"],
            "DEVELOPMENT_TEAM": "S75X4J33FV",
            "CODE_SIGN_STYLE": "Automatic",
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
