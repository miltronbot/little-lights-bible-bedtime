
import Foundation

// MARK: - Voice Options

struct ElevenLabsVoice: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let gender: String
    let category: String       // "premade", "cloned", "professional", etc.
    let previewURL: String?    // direct URL to a short audio preview

    init(id: String, name: String, description: String, gender: String,
         category: String = "premade", previewURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.gender = gender
        self.category = category
        self.previewURL = previewURL
    }

    // Fallback voices shown before the user's API key is verified
    static let defaults: [ElevenLabsVoice] = [
        ElevenLabsVoice(id: "oWAxZDx7w5VEj9dCyTzz", name: "Grace",   description: "Warm & Gentle",    gender: "female"),
        ElevenLabsVoice(id: "21m00Tcm4TlvDq8ikWAM", name: "Rachel",  description: "Calm & Clear",      gender: "female"),
        ElevenLabsVoice(id: "cgSgspJ2msm6clMCkdW9", name: "Jessica", description: "Sweet Storyteller", gender: "female"),
        ElevenLabsVoice(id: "D38z5RcWu1voky8WS1ja", name: "Fin",     description: "Warm & Soothing",   gender: "male"),
        ElevenLabsVoice(id: "N2lVS1w4EtoT3dr4eOWO", name: "Callum",  description: "Classic Narrator",  gender: "male"),
        ElevenLabsVoice(id: "TX3LPaxmHKxFdv7VOQHJ", name: "Liam",    description: "Gentle & Kind",     gender: "male"),
    ]

    // Legacy alias so existing code compiles unchanged
    static var all: [ElevenLabsVoice] { defaults }

    static let defaultVoiceID = "oWAxZDx7w5VEj9dCyTzz" // Grace
}

// MARK: - Errors

enum ElevenLabsError: LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case rateLimited
    case invalidResponse
    case apiError(Int, String?)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your ElevenLabs API key in Settings to enable voice narration."
        case .invalidAPIKey:
            return "Invalid ElevenLabs API key. Please check Settings."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .invalidResponse:
            return "Unexpected response from ElevenLabs. Please try again."
        case .apiError(let code, let message):
            return "ElevenLabs error (\(code))\(message.map { ": \($0)" } ?? ""). Please try again."
        }
    }
}

// MARK: - Service

final class ElevenLabsService {
    static let shared = ElevenLabsService()

    private let cacheDirectory: URL
    private let session: URLSession

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        cacheDirectory = docs.appendingPathComponent("ElevenLabsCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        session = URLSession(configuration: config)
    }

    // MARK: - Cache

    private func cacheURL(storyID: String, voiceID: String) -> URL {
        cacheDirectory.appendingPathComponent("\(storyID)_\(voiceID).mp3")
    }

    func cachedURL(storyID: String, voiceID: String) -> URL? {
        let url = cacheURL(storyID: storyID, voiceID: voiceID)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func cacheSize() -> String {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return "0 MB" }

        let bytes = files.compactMap {
            try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize
        }.reduce(0, +)

        let mb = Double(bytes) / 1_048_576
        return mb < 1 ? String(format: "%.0f KB", mb * 1024) : String(format: "%.1f MB", mb)
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func clearCachedAudio(storyID: String, voiceID: String) {
        let url = cacheURL(storyID: storyID, voiceID: voiceID)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Fetch Voices from API

    /// Fetches all voices available to this API key — including premade, cloned, and professional voices.
    /// Returns the full list sorted: cloned/professional first (user's own voices), then premade.
    func fetchVoices(apiKey: String) async throws -> [ElevenLabsVoice] {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ElevenLabsError.missingAPIKey
        }

        guard let url = URL(string: "https://api.elevenlabs.io/v1/voices") else {
            throw ElevenLabsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey.trimmingCharacters(in: .whitespaces), forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200: break
        case 401: throw ElevenLabsError.invalidAPIKey
        case 429: throw ElevenLabsError.rateLimited
        default:
            let msg = String(data: data, encoding: .utf8)
            throw ElevenLabsError.apiError(httpResponse.statusCode, msg)
        }

        // Parse response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let voicesArray = json["voices"] as? [[String: Any]] else {
            throw ElevenLabsError.invalidResponse
        }

        let voices: [ElevenLabsVoice] = voicesArray.compactMap { v in
            guard let voiceID = v["voice_id"] as? String,
                  let name    = v["name"]     as? String else { return nil }

            let labels      = v["labels"]       as? [String: String] ?? [:]
            let category    = v["category"]     as? String ?? "premade"
            let previewURL  = v["preview_url"]  as? String

            // Build a human-readable description from ElevenLabs labels
            var parts: [String] = []
            if let accent = labels["accent"],      !accent.isEmpty  { parts.append(accent.capitalized) }
            if let age    = labels["age"],          !age.isEmpty     { parts.append(age.capitalized) }
            if let desc   = labels["description"], !desc.isEmpty    { parts.append(desc.capitalized) }
            if let useCase = labels["use case"],   !useCase.isEmpty { parts.append(useCase.capitalized) }
            let description = parts.isEmpty ? category.capitalized : parts.joined(separator: " · ")

            let gender = labels["gender"] ?? "other"

            return ElevenLabsVoice(
                id: voiceID,
                name: name,
                description: description,
                gender: gender,
                category: category,
                previewURL: previewURL
            )
        }

        // Sort: user's own voices (cloned/professional) first, premade after — alphabetical within each group
        return voices.sorted {
            let rankA = Self.categoryRank($0.category)
            let rankB = Self.categoryRank($1.category)
            return rankA != rankB ? rankA < rankB : $0.name < $1.name
        }
    }

    private static func categoryRank(_ category: String) -> Int {
        switch category.lowercased() {
        case "cloned":       return 0
        case "professional": return 1
        case "generated":    return 2
        default:             return 3   // premade
        }
    }

    // MARK: - Generate

    func generateAudio(
        storyID: String,
        text: String,
        voiceID: String,
        apiKey: String
    ) async throws -> URL {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ElevenLabsError.missingAPIKey
        }

        // Return cached audio if available
        if let cached = cachedURL(storyID: storyID, voiceID: voiceID) {
            return cached
        }

        // Build request
        let endpoint = "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)"
        guard let url = URL(string: endpoint) else {
            throw ElevenLabsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey.trimmingCharacters(in: .whitespaces), forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        // Clean text — strip any markdown / extra whitespace
        let cleanedText = text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let body: [String: Any] = [
            "text": cleanedText,
            "model_id": "eleven_turbo_v2_5",
            "voice_settings": [
                "stability": 0.6,
                "similarity_boost": 0.8,
                "style": 0.2,
                "use_speaker_boost": true,
                "speed": 0.9
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Perform request
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw ElevenLabsError.invalidAPIKey
        case 429:
            throw ElevenLabsError.rateLimited
        default:
            let message = String(data: data, encoding: .utf8)
            throw ElevenLabsError.apiError(httpResponse.statusCode, message)
        }

        // Write to cache
        let destination = cacheURL(storyID: storyID, voiceID: voiceID)
        try data.write(to: destination, options: .atomic)
        return destination
    }
}
