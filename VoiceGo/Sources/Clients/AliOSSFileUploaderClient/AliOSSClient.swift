import Foundation
import DependenciesMacros
import UIKit

@DependencyClient
public struct AliOssFileUploaderClient {
    var uploadContent: @Sendable (UploadFileType) async -> AsyncThrowingStream<UploadFileResult, Error> = { _ in .never }
}
