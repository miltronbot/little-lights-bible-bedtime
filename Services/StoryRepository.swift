
import Foundation

enum StoryRepositoryError: LocalizedError {
    case fileNotFound
    case failedToDecode(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The stories file could not be found in the app bundle."
        case .failedToDecode:
            return "Failed to decode the stories file. The file may be corrupted."
        }
    }
}

final class StoryRepository {
    func loadStories() throws -> [Story] {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json") else {
            throw StoryRepositoryError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Story].self, from: data)
        } catch {
            throw StoryRepositoryError.failedToDecode(error)
        }
    }
}
