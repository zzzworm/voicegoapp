import Dependencies

extension DependencyValues {
	public var uploader: AliOssFileUploaderClient {
		get { self[AliOssFileUploaderClient.self] }
		set { self[AliOssFileUploaderClient.self] = newValue }
	}
}
