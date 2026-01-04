//
//  WordListView.swift
//  LingoLearn
//
//  Browse and search all vocabulary words
//

import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WordListViewModel?
    @State private var selectedWord: Word?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let vm = viewModel {
                    // Search bar
                    SearchBar(text: Binding(
                        get: { vm.searchText },
                        set: { vm.searchText = $0 }
                    ))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Filter chips
                    filterSection(viewModel: vm)

                    // Word count and sort button
                    HStack {
                        Text("\(vm.filteredWords.count) 个单词")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Menu {
                            ForEach(WordListFilter.SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    withAnimation {
                                        vm.sortOption = option
                                    }
                                }) {
                                    Label(option.displayName, systemImage: option.icon)
                                    if vm.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: vm.sortOption.icon)
                                Text(vm.sortOption.displayName)
                                    .font(.caption)
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    // Word list
                    if vm.filteredWords.isEmpty {
                        emptyStateView
                    } else {
                        wordList(viewModel: vm)
                    }
                } else {
                    ProgressView("加载中...")
                }
            }
            .navigationTitle("词库")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel == nil {
                    viewModel = WordListViewModel(modelContext: modelContext)
                }
            }
            .sheet(item: $selectedWord) { word in
                WordDetailSheet(word: word)
            }
        }
    }

    private func filterSection(viewModel: WordListViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Category filter
                ForEach(WordListFilter.Category.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        count: viewModel.countFor(category: category)
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                    }
                }

                Divider()
                    .frame(height: 24)

                // Mastery filter
                ForEach(WordListFilter.Mastery.allCases, id: \.self) { mastery in
                    FilterChip(
                        title: mastery.displayName,
                        isSelected: viewModel.selectedMastery == mastery,
                        color: mastery.color,
                        count: mastery == .all ? nil : viewModel.countFor(mastery: mastery)
                    ) {
                        withAnimation {
                            viewModel.selectedMastery = mastery
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func wordList(viewModel: WordListViewModel) -> some View {
        List {
            ForEach(viewModel.filteredWords) { word in
                WordListRow(word: word)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedWord = word
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Enhanced empty state icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.accentColor.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)

                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.secondary, .secondary.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("没有找到单词")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("尝试调整搜索条件或筛选器")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Suggestion chips
            HStack(spacing: 10) {
                SuggestionChip(text: "清除搜索", icon: "xmark.circle")
                SuggestionChip(text: "显示全部", icon: "list.bullet")
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Suggestion Chip

struct SuggestionChip: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isActive = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    isActive ?
                    LinearGradient(colors: [.accentColor, .accentColor.opacity(0.7)], startPoint: .top, endPoint: .bottom) :
                    LinearGradient(colors: [.secondary], startPoint: .top, endPoint: .bottom)
                )
                .font(.body.weight(.medium))

            TextField("搜索单词或释义...", text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isActive = newValue
                    }
                }

            if !text.isEmpty {
                Button(action: {
                    HapticManager.shared.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive ? Color.accentColor.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .accentColor
    var count: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                if let count = count {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? color : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: isSelected ? [.white.opacity(0.95), .white.opacity(0.9)] : [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4, y: 2)
        }
        .buttonStyle(FilterChipButtonStyle())
    }
}

struct FilterChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Word List Row

struct WordListRow: View {
    let word: Word
    @StateObject private var speechService = SpeechService.shared
    @State private var isPressed = false
    @State private var appeared = false

    private var masteryIcon: String {
        switch word.masteryLevel {
        case .new: return "sparkle"
        case .learning: return "book.fill"
        case .reviewing: return "arrow.clockwise"
        case .mastered: return "checkmark.circle.fill"
        }
    }

    private var masteryColors: [Color] {
        switch word.masteryLevel {
        case .new: return [.gray, .gray.opacity(0.7)]
        case .learning: return [.orange, .yellow]
        case .reviewing: return [.blue, .cyan]
        case .mastered: return [.green, .mint]
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Mastery indicator with icon and glow
            ZStack {
                // Subtle glow for mastered words
                if word.masteryLevel == .mastered {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.green.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 25
                            )
                        )
                        .frame(width: 40, height: 40)
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: masteryColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: masteryColors.first?.opacity(0.3) ?? .clear, radius: 4, y: 2)

                Image(systemName: masteryIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(word.english)
                        .font(.body)
                        .fontWeight(.semibold)

                    Text(word.phonetic)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 8) {
                    Text(word.partOfSpeech)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())

                    Text(word.chinese)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Favorite indicator with animation
            if word.isFavorite {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.pink.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 15
                            )
                        )
                        .frame(width: 28, height: 28)

                    Image(systemName: "heart.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .font(.subheadline)
                }
                .scaleEffect(appeared ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: appeared)
            }

            // Speak button with enhanced styling
            Button(action: {
                HapticManager.shared.impact()
                speechService.speak(text: word.english)
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.12), Color.cyan.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)

                    Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.subheadline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.variableColor.iterative, value: speechService.isSpeaking)
                }
            }
            .buttonStyle(WordRowButtonStyle())
        }
        .padding(.vertical, 8)
        .onAppear {
            appeared = true
        }
    }
}

private struct WordRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Word Detail Sheet

struct WordDetailSheet: View {
    let word: Word
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechService = SpeechService.shared
    @State private var isFavorite: Bool = false
    @State private var showContent = false
    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .center, spacing: 16) {
                        // Mastery badge
                        HStack(spacing: 8) {
                            Image(systemName: masteryIcon)
                                .font(.caption)
                            Text(word.masteryLevel.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [word.masteryLevel.color, word.masteryLevel.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.5)

                        Text(word.english)
                            .font(.system(size: 42, weight: .bold))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        Text(word.phonetic)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .opacity(showContent ? 1 : 0)

                        // Audio button with animation
                        Button(action: {
                            HapticManager.shared.impact()
                            speechService.speak(text: word.english)
                        }) {
                            ZStack {
                                // Outer glow
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.blue.opacity(0.2), .clear],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 45
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .opacity(speechService.isSpeaking ? 1 : 0.5)

                                // Sound wave rings when speaking
                                if speechService.isSpeaking {
                                    ForEach(0..<2, id: \.self) { i in
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.3), .cyan.opacity(0.1)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                ),
                                                lineWidth: 2
                                            )
                                            .frame(width: 60 + CGFloat(i * 15), height: 60 + CGFloat(i * 15))
                                            .opacity(0.5 - Double(i) * 0.2)
                                    }
                                }

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.15), .cyan.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)

                                Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .symbolEffect(.variableColor.iterative, value: speechService.isSpeaking)
                            }
                        }
                        .buttonStyle(WordRowButtonStyle())
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    Divider()
                        .padding(.horizontal)

                    // Chinese meaning
                    DetailSection(title: "释义", icon: "text.book.closed", color: .blue, showContent: showContent) {
                        HStack(spacing: 12) {
                            Text(word.partOfSpeech)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())

                            Text(word.chinese)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }

                    // Example sentence
                    if !word.exampleSentence.isEmpty {
                        DetailSection(title: "例句", icon: "quote.bubble", color: .purple, showContent: showContent) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(word.exampleSentence)
                                    .font(.body)
                                    .italic()

                                Text(word.exampleTranslation)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Stats
                    DetailSection(title: "学习记录", icon: "chart.bar", color: .green, showContent: showContent) {
                        HStack(spacing: 12) {
                            StatBox(
                                title: "学习次数",
                                value: "\(word.timesStudied)",
                                icon: "book.fill",
                                color: .blue
                            )
                            StatBox(
                                title: "正确次数",
                                value: "\(word.timesCorrect)",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            StatBox(
                                title: "正确率",
                                value: word.timesStudied > 0 ? "\(Int(Double(word.timesCorrect) / Double(word.timesStudied) * 100))%" : "0%",
                                icon: "percent",
                                color: .orange
                            )
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("单词详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .secondary)
                            .scaleEffect(heartScale)
                            .symbolEffect(.bounce, value: isFavorite)
                    }
                    .accessibilityLabel(isFavorite ? "取消收藏" : "添加收藏")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isFavorite = word.isFavorite
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    showContent = true
                }
            }
        }
    }

    private var masteryIcon: String {
        switch word.masteryLevel {
        case .new: return "sparkle"
        case .learning: return "book.fill"
        case .reviewing: return "arrow.clockwise"
        case .mastered: return "star.fill"
        }
    }

    private func toggleFavorite() {
        HapticManager.shared.impact()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            heartScale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                heartScale = 1.0
            }
        }
        isFavorite.toggle()
        word.isFavorite = isFavorite
        try? modelContext.save()
    }
}

// MARK: - Detail Section

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let showContent: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text(title)
                    .font(.headline)
            }

            content
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 15)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var icon: String = "circle.fill"
    var color: Color = .primary

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: appeared)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .contentTransition(.numericText())

            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))

                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.08), color.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 6, y: 3)
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Extensions

extension MasteryLevel {
    var displayName: String {
        switch self {
        case .new: return "新词"
        case .learning: return "学习中"
        case .reviewing: return "复习中"
        case .mastered: return "已掌握"
        }
    }

    var color: Color {
        switch self {
        case .new: return .gray
        case .learning: return .orange
        case .reviewing: return .blue
        case .mastered: return .green
        }
    }
}

#Preview {
    WordListView()
        .modelContainer(for: [Word.self])
}
