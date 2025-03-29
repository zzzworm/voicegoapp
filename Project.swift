import ProjectDescription

let project = Project(
    name: "VoiceGo",
    targets: [
        .target(
            name: "VoiceGo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.zzwormstudio.VoiceGo",
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
        .target(
            name: "VoiceGoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.VoiceGoTests",
            infoPlist: .default,
            sources: ["VoiceGo/Tests/**"],
            resources: [],
            dependencies: [.target(name: "VoiceGo")]
        ),
    ]
)
