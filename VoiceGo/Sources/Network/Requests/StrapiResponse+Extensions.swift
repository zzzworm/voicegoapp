//
//  APIResp.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/21.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import Foundation
import StrapiSwift

extension Pagination: Equatable {

    public static func == (lhs: Pagination, rhs: Pagination) -> Bool {
        return lhs.page == rhs.page &&
            lhs.pageSize == rhs.pageSize &&
            lhs.pageCount == rhs.pageCount &&
            lhs.limit == rhs.limit &&
            lhs.start == rhs.start &&
            lhs.total == rhs.total
    }
}

extension Meta: Equatable {
    public static func == (lhs: Meta, rhs: Meta) -> Bool {
        return lhs.pagination == rhs.pagination
    }
}

extension StrapiResponse: Equatable where T: Equatable {
    public static func == (lhs: StrapiResponse, rhs: StrapiResponse) -> Bool {
        return lhs.data == rhs.data && lhs.meta == rhs.meta
    }
}
