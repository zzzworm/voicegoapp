//
//  MoyaExtended.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/3.
//
import Dispatch
import Foundation
import Moya
import Alamofire
import ComposableArchitecture
import Pulse

private enum SessionKey: DependencyKey {
    static var liveValue: Session {
        let logger: NetworkLogger = NetworkLogger()
        let eventMonitors: [EventMonitor] = [NetworkLoggerEventMonitor(logger: logger)]
        let session = Session(
            configuration: .default,
            interceptor: RetryInterceptor(), // 可选：自定义拦截器
            eventMonitors: eventMonitors
        )
        return session
    }
}

extension DependencyValues {
    var session: Session {
        get {
            self[SessionKey.self]
        }
        set {
            self[SessionKey.self] = newValue
        }
    }
}

// 添加MoyaProvider的异步扩展
extension MoyaProvider {
    func asyncRequest(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func sseRequest(_ target: Target, callbackQueue: DispatchQueue? = .none, handler: @escaping (DataStreamRequest.EventSource) -> Void, completion: @escaping Moya.Completion) -> DataStreamRequest? {

        let endpoint = self.endpoint(target)
        let stubBehavior = self.stubClosure(target)

        // Allow plugins to modify response
        let pluginsWithCompletion: Moya.Completion = { result in
            let processedResult = self.plugins.reduce(result) { $1.process($0, target: target) }
            completion(processedResult)
        }

        var request: URLRequest?
        let performNetworking = { (requestResult: Result<URLRequest, MoyaError>) in

            switch requestResult {
            case .success(let urlRequest):
                request = urlRequest
            case .failure(let error):
                pluginsWithCompletion(.failure(error))
                return
            }

            let networkCompletion: Moya.Completion = { result in
                pluginsWithCompletion(result)
            }
        }
        self.requestClosure(endpoint, performNetworking)
        if let request = request {
            let initialRequest = Session.default.eventSourceRequest(request)
            return initialRequest.responseEventSource(handler: handler)
        } else {
            return nil
        }

    }
}

// MARK: - LOGGER EVENT

struct NetworkLoggerEventMonitor: EventMonitor {
    let logger: NetworkLogger

    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        logger.logTaskCreated(task)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        logger.logDataTask(dataTask, didReceive: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        logger.logTask(task, didFinishCollecting: metrics)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        logger.logTask(task, didCompleteWithError: error)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) {
        logger.logDataTask(dataTask, didReceive: proposedResponse.data)
    }
}
