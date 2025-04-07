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
    
    func sseRequest(_ target: Target, handler:@escaping (DataStreamRequest.EventSource) -> Void) -> DataStreamRequest {
        
        let endpoint = self.endpoint(target)
        var moyaHeaders = HTTPHeaders()
        if let headers = endpoint.httpHeaderFields {
            moyaHeaders = HTTPHeaders(headers)
        }
        let initialRequest = Session.default.eventSourceRequest(endpoint.url, method: endpoint.method, headers: moyaHeaders)
        
        return initialRequest.responseEventSource(handler: handler)
        
        
    }
}
