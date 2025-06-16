import Alamofire

final class RetryInterceptor: RequestInterceptor {

  private var retryLimit: Int = 2

  init(_ retryLimit: Int = 2) {
    self.retryLimit = retryLimit
  }

  func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void
  ) {
    guard let response = request.response else {
      return completion(.doNotRetryWithError(VGError.network(.invalidResponse)))
    }

    switch response.statusCode {
    case 200..<300:
      return completion(.doNotRetry)
    default:
      if request.retryCount < retryLimit {
        return completion(.retry)
      } else {
        return completion(.doNotRetryWithError(VGError.network(.invalidResponse)))
      }
    }
  }
}
