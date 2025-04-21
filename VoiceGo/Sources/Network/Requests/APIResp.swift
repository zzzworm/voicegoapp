//
//  APIResp.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/4/21.
//  Copyright © 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Pagintion : Codable {
    let page : Int
    let pageSize : Int
    let pageCount : Int
    let total : Int
}


struct Metadata : Codable {
    let pagination : Pagintion
}

struct ListResponse<Element : Codable> : Codable {
    let data: [Element]
    let meta: Metadata

}

