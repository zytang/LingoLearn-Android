//
//  WordListViewModel.swift
//  LingoLearn
//
//  ViewModel for word list with search and filter functionality
//

import Foundation
import SwiftData
import Observation

// MARK: - Filter Types

enum WordListFilter {
    enum Category: CaseIterable {
        case all
        case cet4
        case cet6
        case favorites

        var displayName: String {
            switch self {
            case .all: return "全部"
            case .cet4: return "CET-4"
            case .cet6: return "CET-6"
            case .favorites: return "收藏"
            }
        }
    }

    enum Mastery: CaseIterable {
        case all
        case new
        case learning
        case reviewing
        case mastered

        var displayName: String {
            switch self {
            case .all: return "全部"
            case .new: return "新词"
            case .learning: return "学习中"
            case .reviewing: return "复习中"
            case .mastered: return "已掌握"
            }
        }

        var color: Color {
            switch self {
            case .all: return .accentColor
            case .new: return .gray
            case .learning: return .orange
            case .reviewing: return .blue
            case .mastered: return .green
            }
        }

        var masteryLevel: MasteryLevel? {
            switch self {
            case .all: return nil
            case .new: return .new
            case .learning: return .learning
            case .reviewing: return .reviewing
            case .mastered: return .mastered
            }
        }
    }

    enum SortOption: CaseIterable {
        case alphabetical
        case alphabeticalReverse
        case recentlyStudied
        case difficulty
        case mastery

        var displayName: String {
            switch self {
            case .alphabetical: return "A-Z"
            case .alphabeticalReverse: return "Z-A"
            case .recentlyStudied: return "最近学习"
            case .difficulty: return "难度"
            case .mastery: return "掌握度"
            }
        }

        var icon: String {
            switch self {
            case .alphabetical: return "textformat.abc"
            case .alphabeticalReverse: return "textformat.abc"
            case .recentlyStudied: return "clock"
            case .difficulty: return "chart.bar"
            case .mastery: return "star"
            }
        }
    }
}

import SwiftUI

@Observable
class WordListViewModel {
    private let modelContext: ModelContext
    private var allWords: [Word] = []

    var searchText: String = "" {
        didSet {
            filterWords()
        }
    }

    var selectedCategory: WordListFilter.Category = .all {
        didSet {
            filterWords()
        }
    }

    var selectedMastery: WordListFilter.Mastery = .all {
        didSet {
            filterWords()
        }
    }

    var sortOption: WordListFilter.SortOption = .alphabetical {
        didSet {
            filterWords()
        }
    }

    var filteredWords: [Word] = []

    // Word counts for filter badges
    var totalCount: Int { allWords.count }
    var cet4Count: Int { allWords.filter { $0.category == .cet4 }.count }
    var cet6Count: Int { allWords.filter { $0.category == .cet6 }.count }
    var favoritesCount: Int { allWords.filter { $0.isFavorite }.count }
    var newCount: Int { allWords.filter { $0.masteryLevel == .new }.count }
    var learningCount: Int { allWords.filter { $0.masteryLevel == .learning }.count }
    var reviewingCount: Int { allWords.filter { $0.masteryLevel == .reviewing }.count }
    var masteredCount: Int { allWords.filter { $0.masteryLevel == .mastered }.count }

    func countFor(category: WordListFilter.Category) -> Int {
        switch category {
        case .all: return totalCount
        case .cet4: return cet4Count
        case .cet6: return cet6Count
        case .favorites: return favoritesCount
        }
    }

    func countFor(mastery: WordListFilter.Mastery) -> Int {
        switch mastery {
        case .all: return totalCount
        case .new: return newCount
        case .learning: return learningCount
        case .reviewing: return reviewingCount
        case .mastered: return masteredCount
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAllWords()
    }

    private func loadAllWords() {
        let descriptor = FetchDescriptor<Word>(
            sortBy: [SortDescriptor(\.english, order: .forward)]
        )

        do {
            allWords = try modelContext.fetch(descriptor)
            filterWords()
        } catch {
            print("Error loading words: \(error)")
            allWords = []
            filteredWords = []
        }
    }

    private func filterWords() {
        var result = allWords

        // Apply category filter
        switch selectedCategory {
        case .all:
            break
        case .cet4:
            result = result.filter { $0.category == .cet4 }
        case .cet6:
            result = result.filter { $0.category == .cet6 }
        case .favorites:
            result = result.filter { $0.isFavorite }
        }

        // Apply mastery filter
        if let masteryLevel = selectedMastery.masteryLevel {
            result = result.filter { $0.masteryLevel == masteryLevel }
        }

        // Apply search filter
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            result = result.filter { word in
                word.english.lowercased().contains(searchLower) ||
                word.chinese.contains(searchText) ||
                word.phonetic.lowercased().contains(searchLower)
            }
        }

        // Apply sorting
        result = sortWords(result)

        filteredWords = result
    }

    private func sortWords(_ words: [Word]) -> [Word] {
        switch sortOption {
        case .alphabetical:
            return words.sorted { $0.english.lowercased() < $1.english.lowercased() }
        case .alphabeticalReverse:
            return words.sorted { $0.english.lowercased() > $1.english.lowercased() }
        case .recentlyStudied:
            return words.sorted { ($0.lastStudiedDate ?? .distantPast) > ($1.lastStudiedDate ?? .distantPast) }
        case .difficulty:
            return words.sorted { $0.difficulty > $1.difficulty }
        case .mastery:
            return words.sorted { masteryOrder($0.masteryLevel) < masteryOrder($1.masteryLevel) }
        }
    }

    private func masteryOrder(_ level: MasteryLevel) -> Int {
        switch level {
        case .new: return 0
        case .learning: return 1
        case .reviewing: return 2
        case .mastered: return 3
        }
    }

    func refresh() {
        loadAllWords()
    }

    func toggleFavorite(_ word: Word) {
        word.isFavorite.toggle()
        do {
            try modelContext.save()
            filterWords() // Re-filter in case we're viewing favorites
        } catch {
            print("Error saving favorite: \(error)")
        }
    }
}
