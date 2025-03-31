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
            "ComposableArchitecture":.framework,
            "MarkdownUI":.framework,
            "cmark-gfm":.framework,
            "cmark-gfm-core":.framework,
            "cmark-gfm-extensions":.framework,
            "cmark-gfm-wrapper":.framework,
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

    ]
)
