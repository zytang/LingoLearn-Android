//
//  MultipleChoiceView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct MultipleChoiceView: View {
    let wordCount: Int
    let category: PracticeCategory

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allWords: [Word]
    @Query private var userSettings: [UserSettings]

    @State private var viewModel = PracticeViewModel()
    @State private var selectedAnswer: String? = nil
    @State private var answerSubmitted = false
    @State private var showCorrectAnimation = false
    @State private var showWrongAnimation = false
    @State private var isLoading = true
    @State private var navigateToResults = false

    private var filteredWords: [Word] {
        if category == .all {
            return Array(allWords.shuffled().prefix(wordCount))
        } else {
            let categoryEnum: WordCategory = category == .cet4 ? .cet4 : .cet6
            let filtered = allWords.filter { $0.category == categoryEnum }
            return Array(filtered.shuffled().prefix(wordCount))
        }
    }

    private var timeLimit: Double {
        Double(userSettings.first?.questionTimeLimit ?? 15)
    }

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView(message: "准备测试...")
            } else if viewModel.testCompleted {
                // Navigation happens via navigationDestination
                Color.clear
            } else {
                VStack(spacing: 0) {
                    // Timer bar
                    CountdownTimerBar(
                        timeRemaining: viewModel.timeRemaining,
                        totalTime: viewModel.questionTimeLimit
                    )
                    .padding()

                    // Progress indicator
                    VStack(spacing: 8) {
                        HStack {
                            // Question counter with badge
                            HStack(spacing: 6) {
                                Image(systemName: "list.number")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                Text("题目 \(viewModel.currentQuestionIndex + 1) / \(viewModel.totalQuestions)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Score indicator with gradient
                            HStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green.opacity(0.2), .mint.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 24, height: 24)

                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.green, .mint],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }

                                Text("\(viewModel.correctAnswers)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }

                        // Progress dots
                        QuestionProgressDots(
                            totalQuestions: viewModel.totalQuestions,
                            currentIndex: viewModel.currentQuestionIndex,
                            correctAnswers: viewModel.correctAnswers
                        )
                    }
                    .padding(.horizontal)

                    // Question area
                    if let question = viewModel.currentQuestion {
                        VStack(spacing: 28) {
                            // Instruction badge
                            HStack(spacing: 6) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.caption)
                                Text("选择正确的中文释义")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: .accentColor.opacity(0.3), radius: 6, y: 3)
                            .padding(.top, 20)

                            // English word card
                            VStack(spacing: 14) {
                                // Category indicator
                                HStack(spacing: 4) {
                                    Image(systemName: "book.closed.fill")
                                        .font(.caption2)
                                    Text(question.word.category.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())

                                Text(question.word.english)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary, .primary.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                Text(question.word.phonetic)
                                    .font(.system(size: 18, design: .monospaced))
                                    .foregroundStyle(.secondary)

                                // Part of speech badge
                                Text(question.word.partOfSpeech)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemBackground))

                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [.accentColor.opacity(0.08), .cyan.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.accentColor.opacity(0.2), .cyan.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .accentColor.opacity(0.1), radius: 12, y: 6)
                            .padding(.horizontal)

                            // Answer options
                            VStack(spacing: 14) {
                                ForEach(question.options, id: \.self) { option in
                                    AnswerOptionButton(
                                        text: option,
                                        state: buttonState(for: option),
                                        action: {
                                            if !answerSubmitted {
                                                handleAnswerSelection(option)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                    }
                }
            }

            // Answer animations overlay
            if showCorrectAnimation {
                CorrectAnswerAnimation()
                    .transition(.scale.combined(with: .opacity))
            }

            if showWrongAnimation {
                WrongAnswerAnimation()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("选择题")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("退出") {
                    viewModel.stopTimer()
                    dismiss()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            TestResultsView(
                sessionType: .multipleChoice,
                correctAnswers: viewModel.correctAnswers,
                wrongAnswers: viewModel.wrongAnswers,
                totalQuestions: viewModel.totalQuestions,
                duration: Date().timeIntervalSince(viewModel.sessionStartTime ?? Date())
            )
        }
        .onAppear {
            setupTest()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }

    private func buttonState(for option: String) -> AnswerState {
        if !answerSubmitted {
            return selectedAnswer == option ? .selected : .normal
        } else {
            if option == viewModel.currentQuestion?.correctAnswer {
                return .correct
            } else if option == selectedAnswer {
                return .wrong
            } else {
                return .disabled
            }
        }
    }

    private func handleAnswerSelection(_ answer: String) {
        selectedAnswer = answer
        answerSubmitted = true
        viewModel.submitAnswer(answer)

        let isCorrect = answer == viewModel.currentQuestion?.correctAnswer

        if isCorrect {
            withAnimation {
                showCorrectAnimation = true
            }
        } else {
            withAnimation {
                showWrongAnimation = true
            }
        }

        // Auto-advance after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCorrectAnimation = false
                showWrongAnimation = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                selectedAnswer = nil
                answerSubmitted = false
                viewModel.nextQuestion()

                if viewModel.testCompleted {
                    viewModel.saveSession(modelContext: modelContext, sessionType: .multipleChoice)
                    navigateToResults = true
                }
            }
        }
    }

    private func setupTest() {
        let words = filteredWords

        if words.isEmpty {
            isLoading = false
            return
        }

        viewModel.setupTest(
            words: words,
            testType: .multipleChoice,
            timeLimit: Double(timeLimit)
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            viewModel.startTimer()
        }
    }
}

#Preview {
    NavigationStack {
        MultipleChoiceView(wordCount: 10, category: .all)
            .modelContainer(for: [Word.self, StudySession.self, UserSettings.self])
    }
}
