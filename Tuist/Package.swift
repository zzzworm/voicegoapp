// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            //"Maaku":.staticFramework, "TexturedMaaku":.staticFramework,"TextureSwiftSupport":.staticFramework,
            "Alamofire": .framework,
            "MarkdownUI":.framework,
            "cmark-gfm":.framework,
            "cmark-gfm-core":.framework,
            "cmark-gfm-extensions":.framework,
            "cmark-gfm-wrapper":.framework,
            "Moya":.framework,
            "Pulse":.framework,
            "PulseUI":.framework,
            "SwiftyJSON":.framework,
            "FSRS":.framework,
            "Nuke":.framework,
            "NukeUI":.framework,
            "AliyunOSSSDK":.framework,
            "FBLPromises":.framework,
            "nanopb":.framework,
            "Copyable":.staticFramework,
         ]
    )
#endif

let package = Package(
    name: "VoiceGo",
    dependencies: [
        // Add your own dependencies here:
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        // .package(url: "https://github.com/zzzworm/Maaku.git", branch: "master"),
        // .package(url: "https://github.com/FluidGroup/TextureSwiftSupport.git", from: "3.23.0"),
        // .package(url: "https://github.com/zzzworm/TexturedMaaku.git", branch: "master"),
        .package(url:"https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.18.0"),
        .package(url:"https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.1"),
        .package(url: "https://github.com/swiftlang/swift-cmark", from: "0.5.0"),
        .package(url:"https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url:"https://github.com/kean/Pulse.git", from: "5.1.3"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url:"https://github.com/open-spaced-repetition/swift-fsrs.git", from: "5.0.0"),
        .package(url:"https://github.com/kean/Nuke.git", from: "12.0.0"),
        .package(url:"https://github.com/zangqilong198812/aliyun-oss-ios-sdk.git", branch:"main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.2.0")),
        .package(url: "https://github.com/openid/AppAuth-iOS.git", .upToNextMajor(from: "1.7.0")),
        .package(url:"https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url:"https://github.com/google/gtm-session-fetcher.git", from: "3.5.0"),
        .package(url:"https://github.com/google/GTMAppAuth.git",from: "4.1.0"),
        .package(url: "https://github.com/kean/Get", from: "2.2.1"),
        .package(url:"https://github.com/MojtabaHs/iPhoneNumberField.git", from: "0.10.0"),
        .package(url:"https://github.com/airbnb/lottie-ios", from: "4.0.0"),
        .package(url:"https://github.com/alickbass/CodableFirebase", from: "0.2.0"),
        .package(url:"https://github.com/tonymillion/Reachability", from: "3.2.0"),
        .package(url:"https://github.com/jrendel/SwiftKeychainWrapper.git", from: "4.0.0"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.1.0"),
        .package(url: "https://github.com/fatbobman/IsScrolling.git", from: "1.2.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect.git", from: "1.3.0"),
        .package(url:"https://github.com/johnno1962/InjectionNext.git", from: "1.3.0"),
        .package(url :"https://github.com/johnno1962/HotSwiftUI.git", from:"1.2.1"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "4.1.0"),
        .package(url: "https://github.com/yanyin1986/WechatOpenSDK.git", from: "2.0.4"),
        .package(url: "https://github.com/agisilaos/ColorKit.git", from: "1.6.0"),
        .package(url: "https://github.com/yannickl/DynamicColor.git", from: "5.0.0"),
        .package(url: "https://github.com/eu-digital-identity-wallet/SwiftCopyableMacro.git", from: "0.0.3"),
        .package(url: "https://github.com/Nirma/UIFontComplete.git", from: "6.2.0"),
        .package(path: "../Packages/exyteChat"),
        .package(path: "../Packages/strapi-swift"),
        .package(path: "../Packages/ActivityIndicatorView"),
    ]
)
