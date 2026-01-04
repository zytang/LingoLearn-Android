import Foundation
import SwiftData
import OSLog

struct WordData: Codable {
    let english: String
    let chinese: String
    let phonetic: String
    let partOfSpeech: String
    let exampleSentence: String
    let exampleTranslation: String
    let difficulty: Int

    /// Validates that the word data has required non-empty fields
    var isValid: Bool {
        !english.trimmingCharacters(in: .whitespaces).isEmpty &&
        !chinese.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct WordsJSON: Codable {
    let category: String
    let words: [WordData]
}

/// Errors that can occur during data seeding
enum DataSeederError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidData(String)
    case decodingFailed(String, Error)
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Could not find resource file: \(filename).json"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .decodingFailed(let filename, let error):
            return "Failed to decode \(filename): \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        }
    }
}

/// Result of a seeding operation
struct SeedingResult {
    let totalWordsSeeded: Int
    let skippedWords: Int
    let errors: [DataSeederError]

    var isSuccess: Bool {
        errors.isEmpty
    }
}

final class DataSeederService {
    private static let hasSeededKey = AppConstants.Data.hasSeededDataKey
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LingoLearn", category: "DataSeeder")

    /// Seeds initial data if not already seeded
    /// - Parameter modelContext: The SwiftData model context
    /// - Returns: Result indicating success/failure and statistics
    @discardableResult
    static func seedDataIfNeeded(modelContext: ModelContext) -> SeedingResult {
        // Check if data has already been seeded
        let hasSeeded = UserDefaults.standard.bool(forKey: hasSeededKey)
        guard !hasSeeded else {
            logger.info("Data already seeded, skipping...")
            return SeedingResult(totalWordsSeeded: 0, skippedWords: 0, errors: [])
        }

        logger.info("Starting data seeding...")

        var totalWords = 0
        var totalSkipped = 0
        var errors: [DataSeederError] = []

        // Seed CET-4 words
        let cet4Result = seedWords(from: "cet4_words", category: .cet4, modelContext: modelContext)
        totalWords += cet4Result.seeded
        totalSkipped += cet4Result.skipped
        if let error = cet4Result.error {
            errors.append(error)
        }

        // Seed CET-6 words
        let cet6Result = seedWords(from: "cet6_words", category: .cet6, modelContext: modelContext)
        totalWords += cet6Result.seeded
        totalSkipped += cet6Result.skipped
        if let error = cet6Result.error {
            errors.append(error)
        }

        // Create default UserStats
        let userStats = UserStats()
        modelContext.insert(userStats)

        // Create default UserSettings
        let userSettings = UserSettings()
        modelContext.insert(userSettings)

        // Save context
        do {
            try modelContext.save()
            UserDefaults.standard.set(true, forKey: hasSeededKey)
            logger.info("Data seeding completed: \(totalWords) words seeded, \(totalSkipped) skipped")
        } catch {
            logger.error("Failed to save seeded data: \(error.localizedDescription)")
            errors.append(.saveFailed(error))
        }

        return SeedingResult(totalWordsSeeded: totalWords, skippedWords: totalSkipped, errors: errors)
    }

    private static func seedWords(from filename: String, category: WordCategory, modelContext: ModelContext) -> (seeded: Int, skipped: Int, error: DataSeederError?) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            logger.error("Could not find \(filename).json in bundle")
            return (0, 0, .fileNotFound(filename))
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let wordsJSON = try decoder.decode(WordsJSON.self, from: data)

            var seededCount = 0
            var skippedCount = 0

            for wordData in wordsJSON.words {
                // Validate word data
                guard wordData.isValid else {
                    logger.warning("Skipping invalid word entry in \(filename): empty english or chinese field")
                    skippedCount += 1
                    continue
                }

                let word = Word(
                    english: wordData.english.trimmingCharacters(in: .whitespaces),
                    chinese: wordData.chinese.trimmingCharacters(in: .whitespaces),
                    phonetic: wordData.phonetic,
                    partOfSpeech: wordData.partOfSpeech,
                    exampleSentence: wordData.exampleSentence,
                    exampleTranslation: wordData.exampleTranslation,
                    category: category,
                    difficulty: max(1, min(5, wordData.difficulty)) // Clamp difficulty 1-5
                )
                modelContext.insert(word)
                seededCount += 1
            }

            logger.info("Seeded \(seededCount) words from \(filename), skipped \(skippedCount)")
            return (seededCount, skippedCount, nil)
        } catch let decodingError as DecodingError {
            logger.error("Decoding error for \(filename): \(decodingError.localizedDescription)")
            return (0, 0, .decodingFailed(filename, decodingError))
        } catch {
            logger.error("Error reading \(filename): \(error.localizedDescription)")
            return (0, 0, .decodingFailed(filename, error))
        }
    }

    /// Reset seeding flag (useful for development/testing)
    static func resetSeedingFlag() {
        UserDefaults.standard.removeObject(forKey: hasSeededKey)
        logger.info("Seeding flag reset - data will be re-seeded on next launch")
    }

    /// Check if data has been seeded
    static var hasSeededData: Bool {
        UserDefaults.standard.bool(forKey: hasSeededKey)
    }
}
