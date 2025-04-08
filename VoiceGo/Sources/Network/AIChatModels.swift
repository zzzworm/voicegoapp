import Foundation
import SwiftyJSON


public struct ConversationQuery: Equatable, Encodable {
    enum SortBy: String, CaseIterable,Encodable {
        case created_latest = "-created_at"
        case created_oldest = "created_at"
        case updated_latest = "-updated_at"
        case updated_oldest = "updated_at"
    }
    let user: String
    let last_id: String? = nil
    let limit: Int = 10
    let sort_by : SortBy = .updated_latest
}

public enum ResponseMode: String, CaseIterable , Encodable {
    case blocking = "blocking"
    case streaming = "streaming"
}

public struct MessageQuery: Equatable , Encodable {
    let user: String
    let conversation_id: String
    let first_id_id: String? = nil
    let limit: Int = 10
}

public struct ChatMessageReq: Equatable, Encodable {
    let user: String
    var conversation_id: String?
    let query: String
    let response_mode : ResponseMode = .streaming
    let auto_generate_name: Bool = true
    let inputs: [String: String] = [:]
}



struct ConversationRsp: Codable {
    let limit: Int
    let hasMore: Bool
    let data: [ConversationData]

    enum CodingKeys: String, CodingKey {
        case limit
        case hasMore = "has_more"
        case data
    }
}

struct ConversationData: Codable {
    let id: String
    let name: String
    let inputs: JSON
    let status: String
    let createdAt: Int
    let updatedAt: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case inputs
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.inputs = try container.decode(JSON.self, forKey: .inputs)
        self.status = try container.decode(String.self, forKey: .status)
        self.createdAt = try container.decode(Int.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Int.self, forKey: .updatedAt)
    }
}

struct MessageData: Codable {
    let id: String
    let conversationId: String
    let parentMessageId: String
    let inputs: [String: String]
    let query: String
    var answer: String
    let messageFiles: [String]
    let feedback: String?
    let retrieverResources: [String]
    let createdAt: Int
    let agentThoughts: [String]
    let status: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case parentMessageId = "parent_message_id"
        case inputs
        case query
        case answer
        case messageFiles = "message_files"
        case feedback
        case retrieverResources = "retriever_resources"
        case createdAt = "created_at"
        case agentThoughts = "agent_thoughts"
        case status
        case error
    }
    
    // 处理空值默认初始化
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        conversationId = try container.decode(String.self, forKey: .conversationId)
        parentMessageId = try container.decode(String.self, forKey: .parentMessageId)
        inputs = try container.decodeIfPresent([String: String].self, forKey: .inputs) ?? [:]
        query = try container.decode(String.self, forKey: .query)
        answer = try container.decode(String.self, forKey: .answer)
        messageFiles = try container.decodeIfPresent([String].self, forKey: .messageFiles) ?? []
        feedback = try container.decodeIfPresent(String.self, forKey: .feedback)
        retrieverResources = try container.decodeIfPresent([String].self, forKey: .retrieverResources) ?? []
        createdAt = try container.decode(Int.self, forKey: .createdAt)
        agentThoughts = try container.decodeIfPresent([String].self, forKey: .agentThoughts) ?? []
        status = try container.decode(String.self, forKey: .status)
        error = try container.decodeIfPresent(String.self, forKey: .error)
    }
}

