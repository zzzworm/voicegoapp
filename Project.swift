import ProjectDescription

let debugDependencies : [TargetDependency] = [
                .external(name: "PulseUI"),
                .external(name: "InjectionNext"),
                .external(name: "HotSwiftUI"),
]
let commonDependencies : [TargetDependency] = [
                // .external(name: "Maaku"),
                // .external(name: "TexturedMaaku"),
                // .external(name:"TextureSwiftSupport")
                .external(name: "Alamofire"),
                .external(name: "ComposableArchitecture"),
                .external(name: "MarkdownUI"),
                .external(name: "cmark-gfm"),
                .external(name: "Moya"),
                .external(name: "Pulse"),
                .external(name: "SwiftyJSON"),
                .external(name: "FSRS"),
                .external(name: "Nuke"),
                .external(name: "NukeUI"),
                .external(name: "AliyunOSSSDK"),
                .external(name: "AppAuth"),
                .external(name: "FBLPromises"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseInstallations"),
                .external(name: "GoogleAppMeasurement"),
                .external(name: "GoogleDataTransport"),
                .external(name: "GoogleSignIn"),
                .external(name: "GoogleSignInSwift"),
                .external(name: "GTMAppAuth"),
                .external(name: "GTMSessionFetcher"),
                .external(name: "nanopb"),
                .external(name: "Get"),
                .external(name: "iPhoneNumberField"),
                .external(name: "Lottie"),
                .external(name: "FirebaseFirestore"),
                .external(name: "CodableFirebase"),
                .external(name: "Reachability"),
                .external(name: "SwiftKeychainWrapper"),
                .external(name: "SharingGRDB"),
                .external(name: "StrapiSwift"),
                .external(name: "IsScrolling"),
                .external(name: "SwiftUIIntrospect"),
                .external(name: "PopupView"),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
                .external(name: "ColorKit"),   
                .external(name: "DynamicColor"),
                .external(name: "Copyable"),
                .external(name: "UIFontComplete"),
                .external(name: "ExyteChat"),
                .sdk(name: "AuthenticationServices", type: .framework),
            ]

let targetActions: [TargetScript] = [

    .post(script: """
export RESOURCES="/Applications/InjectionNext.app/Contents/Resources"
if [ -f "$RESOURCES/copy_bundle.sh" ]; then
    "$RESOURCES/copy_bundle.sh"
fi
""",
        name: "Injection Next Script",
        basedOnDependencyAnalysis: false)
]

let project = Project(
    name: "VoiceGo",
    organizationName: "Shanghai Souler Information Technology Co., Ltd.",
    packages:[
        .remote(url: "https://github.com/SimplyDanny/SwiftLintPlugins", requirement: .upToNextMajor(from: "0.59.1")),
    ],
    targets: [
        .target(
            name: "VoiceGo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.souler.cn.VoiceGo",
            deploymentTargets: .iOS("17.0"),
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
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["com.googleusercontent.apps.154047246991-i35evo607leghoonomt7qnci8sb03nv6"]
                        ],
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["com.googleusercontent.apps.807659277596-8je49j3lvjk6mbumn8nackgegq1tj9bk"]
                        ]
                    ],
                    "CFBundleShortVersionString": "1.0.0",
                    "LSApplicationCategoryType": "public.app-category.education",
                ]
            ),
            sources: ["VoiceGo/Sources/**"],
            resources: [
                "VoiceGo/Resources/**",
                "VoiceGo/Sources/Configuration/config.plist"
            ],
            scripts : targetActions,
            dependencies: Environment.skipDependencies.getBoolean(default: false) ? commonDependencies : commonDependencies + debugDependencies ,
            settings: .settings(base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC -force_load",
            "DEVELOPMENT_ASSET_PATHS": ["VoiceGo/Resources/PreviewContent/PreviewAssets.xcassets"],
            "DEVELOPMENT_TEAM": "S75X4J33FV",
            "CODE_SIGN_STYLE": "Automatic",
            "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            "LOCALIZATION_EXPORT_SUPPORTED": "YES",
            "LOCALIZED_STRING_SWIFTUI_SUPPORT": "YES",
            "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
            "ASSETCATALOG_COMPILER_LOCALIZATION": "zh-Hans",
            "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
            ],
            debug: [
                "OTHER_LDFLAGS": " $(inherited) -Xlinker -interposable -ObjC -force_load",
            ]
            ),
            additionalFiles: [
                "VoiceGo/VoiceGo.entitlements"
            ]
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
            bundleId: "com.souler.cn.VoiceGoTests",
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
