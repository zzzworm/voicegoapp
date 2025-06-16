//
//  DictionaryAPIClient.swift
//  VoiceGo
//
//  Created by Cascade on 2025-06-14.
//

import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct DictionaryApiClient {
    public var entries: @Sendable (_ word: String) async throws -> [DictionaryEntry]
}

public struct DictionaryEntry: Codable, Equatable, Sendable {
    public let word: String
    public let phonetics: [Phonetic]
    public let meanings: [Meaning]
    public let license: License
    public let sourceUrls: [String]
}

public struct Phonetic: Codable, Equatable, Sendable {
    public let audio: String
    public let sourceUrl: String?
    public let license: License?
    public let text: String?
}

public struct Meaning: Codable, Equatable, Sendable {
    public let partOfSpeech: String
    public let definitions: [Definition]
    public let synonyms: [String]
    public let antonyms: [String]
}

public struct Definition: Codable, Equatable, Sendable {
    public let definition: String
    public let synonyms: [String]
    public let antonyms: [String]
    public let example: String?
}

public struct License: Codable, Equatable, Sendable {
    public let name: String
    public let url: String
}

extension DictionaryApiClient: DependencyKey {
    public static let liveValue: Self = {
        let session = URLSession.shared
        return Self(
            entries: { word in
                let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)")!
                let (data, _) = try await session.data(from: url)
                let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
                return entries
            }
        )
    }()
}

extension DictionaryApiClient: TestDependencyKey {
    public static let previewValue = Self(
        entries: { _ in
            [
                .init(word: "hello", phonetics: [.init(audio: "https://api.dictionaryapi.dev/media/pronunciations/en/hello-au.mp3",
                                                       sourceUrl: "https://commons.wikimedia.org/w/index.php?curid=75797336",
                                                       license: .init(name: "BY-SA 4.0",
                                                                                                                                             url: "https://creativecommons.org/licenses/by-sa/4.0"),
                                                       text: "/həˈləʊ/")],
                      meanings: [.init(partOfSpeech: "noun",
                                       definitions: [.init(definition: "\"Hello!\" or an equivalent greeting.", synonyms: [], antonyms: [], example: nil)],
                                       synonyms: ["greeting"], antonyms: [])],
                      license: .init(name: "CC BY-SA 3.0", url: "https://creativecommons.org/licenses/by-sa/3.0"),
                      sourceUrls: ["https://en.wiktionary.org/wiki/hello"])
            ]
        }
    )

    public static let testValue = Self(
        entries: { _ in
            [
                .init(word: "hello", phonetics: [.init(audio: "https://api.dictionaryapi.dev/media/pronunciations/en/hello-au.mp3",
                                                       sourceUrl: "https://commons.wikimedia.org/w/index.php?curid=75797336",
                                                       license: .init(name: "BY-SA 4.0", url: "https://creativecommons.org/licenses/by-sa/4.0"),
                                                       text: "/həˈləʊ/")],
                      meanings: [.init(partOfSpeech: "noun",
                                       definitions: [.init(definition: "\"Hello!\" or an equivalent greeting.", synonyms: [], antonyms: [], example: nil)], synonyms: ["greeting"], antonyms: [])],
                      license: .init(name: "CC BY-SA 3.0", url: "https://creativecommons.org/licenses/by-sa/3.0"),
                      sourceUrls: ["https://en.wiktionary.org/wiki/hello"])
            ]
        }
    )
}

public extension DependencyValues {
    var dictionaryApiClient: DictionaryApiClient {
        get { self[DictionaryApiClient.self] }
        set { self[DictionaryApiClient.self] = newValue }
    }
}
