import Dependencies
import Foundation
import AliyunOSSSDK
import UIKit


/**
 * the url to fetch sts info,for detail please refer to https://help.aliyun.com/document_detail/31920.html
 */
let OSS_STS_URL = "oss_sts_url"



extension AliOssFileUploaderClient: DependencyKey {
    
    public static var liveValue: Self{
        // initialize credential provider,which auto fetch and update sts info from sts url.
        let credentialProvider = OSSAuthCredentialProvider(authServerUrl: OSS_STS_URL)
        
        // set config for oss client networking
        let cfg = OSSClientConfiguration()
        
        let client = OSSClient(endpoint: Configuration.current.ossEndpoint,
                               credentialProvider: credentialProvider,
                               clientConfiguration: cfg)
        let clientActor = AliOssFileUploaderClientActor(client: client)
        return Self(
            uploadContent: { uploadType in
                AsyncThrowingStream { continuation in
                    Task {
                        let fileName = UUID().uuidString
                        var image: UIImage?
                        var fileId: String?
                        var thumbnail: UIImage?
                        var fileURL: URL?
                        var thumbnailURL: URL?
                        switch uploadType {
                        case let .profile(profileImage):
                            image = profileImage
                        case let .photoMessage(photoFileId, photoImage):
                            fileId = photoFileId
                            image = photoImage
                        case let .videoMessage(videoFileId, thumbnailImage, videoFileURL):
                            fileId = videoFileId
                            fileURL = videoFileURL
                            thumbnail = thumbnailImage
                        case let .audioMessage(audioFileId, audioFileURL, _):
                            fileId = audioFileId
                            fileURL = audioFileURL
                        }
                        do{
                            var retUrl : URL?
                            var uploadData : Data?
                            if let image = image {
                                uploadData = image.pngData()
                            }
                            if let fileURL = fileURL {
                                uploadData = try Data(contentsOf: fileURL)
                            }
                            for try await uploadResult in await clientActor.putDataAsync(data: uploadData!, bucketName: Configuration.current.ossbucket, fileName: fileName){
                                if case let .completion(fileId, url) = uploadResult {
                                    retUrl = url
                                }
                                if case let .progress(fileId, progress) = uploadResult {
                                    continuation.yield(UploadFileResult.progress(fileId: fileId, progress: progress))
                                }
                            }
                            continuation.yield(UploadFileResult.completion(fileId: fileId, thumbnailUrl: thumbnailURL, fileUrl: retUrl!))
                            continuation.finish()
                        }
                        catch {
                            continuation.finish(throwing: UploadError.failedToUploadContent("Failed to upload image"))
                        }
                    }
                }
            }
        )
    }
}

private actor AliOssFileUploaderClientActor {
    var client: OSSClient
    init(client: OSSClient) {
        self.client = client
    }
    
    func putDataAsync(data: Data, bucketName: String ,fileName: String) -> AsyncThrowingStream<UploadDataResult, Error> {
        return AsyncThrowingStream<UploadDataResult, Error> { continuation in
            Task {
                let fileUrl = URL(string: "https://\(bucketName).\(Configuration.current.ossEndpoint)/\(fileName)")
                let request = OSSPutObjectRequest()
                request.uploadingData = data
                request.bucketName = bucketName
                request.objectKey = fileName
                request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
                    let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
                    print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
                    continuation.yield(UploadDataResult.progress(fileId: nil, progress: progress))
                };
                
                
                let task = client.putObject(request)
                task.continue({ (t) -> Any? in
                    guard task.error == nil ,let result = task.result as? OSSPutObjectResult else {
                        continuation.finish(throwing:UploadError.failedToUploadContent("Failed to upload image"))
                        return nil
                    }
                    
                    continuation.yield(UploadDataResult.completion(fileId: result.requestId, fileUrl: fileUrl!))
                    continuation.finish()
                    
                    return nil;
                }).waitUntilFinished()
            }
        }
    }
    
    
}
