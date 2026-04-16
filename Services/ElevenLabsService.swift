import Foundation

// MARK: - Character Voice Map

struct CharacterVoiceMap {
    static let voices: [String: String] = [
        // The Big Two
        "God":                      "pqHfZKP75CvOlQylNhV4",  // Bill
        "The Father":               "pqHfZKP75CvOlQylNhV4",  // Bill
        "Jesus":                    "JBFqnCBsd6RMkjVDRZzb",  // George
        // Narrators
        "Narrator":                 "REGEUmIBzUFwSMkNwWo4",  // Lane Sinclair
        "NarratorNT":               "a5jCeyrTh80w2jtEglgc",  // Rachael Sinclair
        "Angel":                    "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        "Angels":                   "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        // OT Heroes
        "Moses":                    "nPczCjzI2devNBz1zQrb",  // Brian
        "David":                    "cjVigY5qzO86Huf0OWal",  // Eric
        "Noah":                     "C9fbwSpEaejywLWx722Z",  // Marcus
        "Abraham":                  "UzI1NsMEV3ni5JRkRSls",  // Alistair
        "Jacob":                    "gcdNeREzHPJpCf9wnB0l",  // Elias
        "Joseph":                   "gcdNeREzHPJpCf9wnB0l",  // Elias
        "Elijah":                   "onwK4e9ZLuTAKqWW03F9",  // Daniel
        "Joshua":                   "nPczCjzI2devNBz1zQrb",  // Brian
        "Gideon":                   "cjVigY5qzO86Huf0OWal",  // Eric
        "Nehemiah":                 "C9fbwSpEaejywLWx722Z",  // Marcus
        "Solomon":                  "UzI1NsMEV3ni5JRkRSls",  // Alistair
        "Samuel":                   "cjVigY5qzO86Huf0OWal",  // Eric
        "Daniel":                   "gcdNeREzHPJpCf9wnB0l",  // Elias
        "Jonah":                    "nPczCjzI2devNBz1zQrb",  // Brian
        "Shadrach":                 "nPczCjzI2devNBz1zQrb",  // Brian
        "Meshach":                  "nPczCjzI2devNBz1zQrb",  // Brian
        "Abednego":                 "nPczCjzI2devNBz1zQrb",  // Brian
        "Adam":                     "REGEUmIBzUFwSMkNwWo4",  // Lane Sinclair
        "Isaac":                    "cgSgspJ2msm6clMCkdW9",  // Jessica
        // OT Women
        "Mary":                     "a5jCeyrTh80w2jtEglgc",  // Rachael Sinclair
        "Hannah":                   "a5jCeyrTh80w2jtEglgc",  // Rachael Sinclair
        "Eve":                      "a5jCeyrTh80w2jtEglgc",  // Rachael Sinclair
        "Ruth":                     "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        "Esther":                   "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        "Mary Magdalene":           "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        "Miriam":                   "cgSgspJ2msm6clMCkdW9",  // Jessica
        "Martha":                   "cgSgspJ2msm6clMCkdW9",  // Jessica
        "Naomi":                    "EXAVITQu4vr4xnSDxMaL",  // Sarah
        "Widow":                    "Qe0sFDUsK280KloQRibK",  // Cari Sinclair
        "Woman at the Well":        "EXAVITQu4vr4xnSDxMaL",  // Sarah
        "Pharaoh's Daughter":      "EXAVITQu4vr4xnSDxMaL",  // Sarah
        // NT Characters
        "Peter":                    "SOYHLrjzK2X1ezoPC6cr",  // Harry
        "Zacchaeus":                "cjVigY5qzO86Huf0OWal",  // Eric
        "Eli":                      "pqHfZKP75CvOlQylNhV4",  // Bill
        "Boaz":                     "C9fbwSpEaejywLWx722Z",  // Marcus
        "Goliath":                  "SOYHLrjzK2X1ezoPC6cr",  // Harry
        "King":                     "onwK4e9ZLuTAKqWW03F9",  // Daniel
        "Nebuchadnezzar":           "onwK4e9ZLuTAKqWW03F9",  // Daniel
        "Shepherd":                 "REGEUmIBzUFwSMkNwWo4",  // Lane Sinclair
        "Shepherds":                "REGEUmIBzUFwSMkNwWo4",  // Lane Sinclair
    ]

    static func voiceID(for character: String) -> String? {
        if let id = voices[character] { return id }
        let lower = character.lowercased()
        return voices.first(where: { $0.key.lowercased() == lower })?.value
    }
}

// MARK: - Story Narrator Type

enum StoryNarratorType: String, Codable {
    case oldTestament = "OT"
    case newTestament = "NT"

    var defaultVoiceID: String {
        switch self {
        case .oldTestament: return "REGEUmIBzUFwSMkNwWo4"  // Lane Sinclair
        case .newTestament: return "a5jCeyrTh80w2jtEglgc"  // Rachael Sinclair
        }
    }
}

// MARK: - Voice Options

struct ElevenLabsVoice: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let gender: String
    let category: String
    let previewURL: String?

    init(id: String, name: String, description: String, gender: String,
         category: String = "premade", previewURL: String? = nil) {
        self.id = id; self.name = name; self.description = description
        self.gender = gender; self.category = category; self.previewURL = previewURL
    }

    static let all: [ElevenLabsVoice] = [
        ElevenLabsVoice(id: "REGEUmIBzUFwSMkNwWo4", name: "Lane Sinclair",    description: "Old Testament Narrator",  gender: "male",   category: "cloned"),
        ElevenLabsVoice(id: "a5jCeyrTh80w2jtEglgc", name: "Rachael Sinclair", description: "New Testament Narrator",  gender: "female", category: "cloned"),
        ElevenLabsVoice(id: "Qe0sFDUsK280KloQRibK", name: "Cari Sinclair",    description: "Angels & Heaven",         gender: "female", category: "cloned"),
        ElevenLabsVoice(id: "pqHfZKP75CvOlQylNhV4", name: "Bill",     description: "God / Father / Eli",         gender: "male"),
        ElevenLabsVoice(id: "JBFqnCBsd6RMkjVDRZzb", name: "George",   description: "Jesus",                      gender: "male"),
        ElevenLabsVoice(id: "nPczCjzI2devNBz1zQrb", name: "Brian",    description: "Moses / Joshua / Jonah",     gender: "male"),
        ElevenLabsVoice(id: "gcdNeREzHPJpCf9wnB0l", name: "Elias",    description: "Jacob / Joseph / Daniel",    gender: "male"),
        ElevenLabsVoice(id: "UzI1NsMEV3ni5JRkRSls", name: "Alistair", description: "Abraham / Solomon",          gender: "male"),
        ElevenLabsVoice(id: "cjVigY5qzO86Huf0OWal", name: "Eric",     description: "David / Gideon / Samuel",    gender: "male"),
        ElevenLabsVoice(id: "C9fbwSpEaejywLWx722Z", name: "Marcus",   description: "Noah / Nehemiah / Boaz",     gender: "male"),
        ElevenLabsVoice(id: "onwK4e9ZLuTAKqWW03F9", name: "Daniel",   description: "Elijah / King",              gender: "male"),
        ElevenLabsVoice(id: "SOYHLrjzK2X1ezoPC6cr", name: "Harry",    description: "Peter / Goliath",            gender: "male"),
        ElevenLabsVoice(id: "EXAVITQu4vr4xnSDxMaL", name: "Sarah",    description: "Naomi / Woman at Well",      gender: "female"),
        ElevenLabsVoice(id: "cgSgspJ2msm6clMCkdW9", name: "Jessica",  description: "Miriam / Martha / Isaac",    gender: "female"),
    ]

    static var defaults: [ElevenLabsVoice] { all }
    static let defaultVoiceID = "REGEUmIBzUFwSMkNwWo4"
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
