//
//  FillInBlankView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct FillInBlankView: View {
    let wordCount: Int
    let category: PracticeCategory

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allWords: [Word]
    @Query private var userSettings: [UserSettings]

    @State private var viewModel = PracticeViewModel()
    @State private var userAnswer: String = ""
    @State private var answerSubmitted = false
    @State private var showCorrectAnimation = false
    @State private var showWrongAnimation = false
    @State private var isLoading = true
    @State private var navigateToResults = false
    @FocusState private var isTextFieldFocused: Bool

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

    private var isAnswerCorrect: Bool {
        guard let correctAnswer = viewModel.currentQuestion?.correctAnswer else { return false }
        return userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == correctAnswer
    }

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView(message: "准备测试...")
            } else if viewModel.testCompleted {
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
                            Text("题目 \(viewModel.currentQuestionIndex + 1) / \(viewModel.totalQuestions)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                                Text("\(viewModel.correctAnswers)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.green)
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
                        VStack(spacing: 32) {
                            // Chinese meaning with enhanced card
                            VStack(spacing: 20) {
                                // Instruction badge
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.line")
                                        .font(.caption)
                                    Text("请写出对应的英文单词")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: .purple.opacity(0.3), radius: 6, y: 3)

                                // Chinese word card
                                VStack(spacing: 12) {
                                    Text(question.word.chinese)
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.primary, .primary.opacity(0.8)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .multilineTextAlignment(.center)

                                    // Hint badge
                                    HStack(spacing: 6) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                        Text("\(question.word.english.count) 个字母")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.yellow.opacity(0.1))
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
                                                    colors: [.purple.opacity(0.08), .pink.opacity(0.05)],
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
                                                colors: [.purple.opacity(0.2), .pink.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: .purple.opacity(0.1), radius: 12, y: 6)

                                if !question.word.exampleSentence.isEmpty {
                                    VStack(spacing: 6) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "text.quote")
                                                .font(.caption2)
                                                .foregroundStyle(.purple)
                                            Text("例句提示")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.secondary)
                                        }

                                        Text(question.word.exampleTranslation)
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6).opacity(0.5))
                                    )
                                }
                            }
                            .padding(.top, 24)
                            .padding(.horizontal)

                            // Answer input with enhanced styling
                            VStack(spacing: 16) {
                                ZStack {
                                    TextField("输入英文单词", text: $userAnswer)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 22, weight: .medium, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 18)
                                        .padding(.horizontal)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(.systemBackground))

                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(
                                                        answerSubmitted ?
                                                            (isAnswerCorrect ?
                                                                LinearGradient(colors: [.green.opacity(0.1), .mint.opacity(0.05)], startPoint: .top, endPoint: .bottom) :
                                                                LinearGradient(colors: [.red.opacity(0.1), .orange.opacity(0.05)], startPoint: .top, endPoint: .bottom)) :
                                                            LinearGradient(colors: [Color.gray.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                                                    )
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    answerSubmitted ?
                                                        (isAnswerCorrect ?
                                                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing) :
                                                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)) :
                                                        LinearGradient(colors: [.accentColor.opacity(isTextFieldFocused ? 0.5 : 0.2)], startPoint: .leading, endPoint: .trailing),
                                                    lineWidth: answerSubmitted ? 2.5 : (isTextFieldFocused ? 2 : 1.5)
                                                )
                                        )
                                        .shadow(
                                            color: answerSubmitted ?
                                                (isAnswerCorrect ? .green.opacity(0.2) : .red.opacity(0.2)) :
                                                .accentColor.opacity(isTextFieldFocused ? 0.15 : 0),
                                            radius: 10, y: 4
                                        )
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .focused($isTextFieldFocused)
                                        .disabled(answerSubmitted)
                                }

                                // Show correct answer if wrong
                                if answerSubmitted && !isAnswerCorrect {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.green, .mint],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 32, height: 32)

                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("正确答案")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            HStack(spacing: 8) {
                                                Text(question.word.english)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: [.green, .mint],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )

                                                Text(question.word.phonetic)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.12), .mint.opacity(0.06)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }

                                // Submit button with enhanced styling
                                if !answerSubmitted {
                                    Button(action: {
                                        HapticManager.shared.impact()
                                        handleSubmit()
                                    }) {
                                        HStack(spacing: 8) {
                                            Text("提交")
                                                .font(.headline)
                                                .fontWeight(.semibold)

                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.title3)
                                        }
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: userAnswer.isEmpty
                                                    ? [.gray.opacity(0.5), .gray.opacity(0.4)]
                                                    : [.accentColor, .accentColor.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .shadow(color: userAnswer.isEmpty ? .clear : .accentColor.opacity(0.4), radius: 10, y: 5)
                                    }
                                    .buttonStyle(FillInBlankButtonStyle())
                                    .disabled(userAnswer.isEmpty)
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
        .navigationTitle("填空题")
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
                sessionType: .fillInBlank,
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

    private func handleSubmit() {
        answerSubmitted = true
        isTextFieldFocused = false
        viewModel.submitAnswer(userAnswer)

        if isAnswerCorrect {
            withAnimation {
                showCorrectAnimation = true
            }
        } else {
            withAnimation {
                showWrongAnimation = true
            }
        }

        // Auto-advance after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCorrectAnimation = false
                showWrongAnimation = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                userAnswer = ""
                answerSubmitted = false
                viewModel.nextQuestion()

                if viewModel.testCompleted {
                    viewModel.saveSession(modelContext: modelContext, sessionType: .fillInBlank)
                    navigateToResults = true
                } else {
                    isTextFieldFocused = true
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
            testType: .fillInBlank,
            timeLimit: timeLimit
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            viewModel.startTimer()
            isTextFieldFocused = true
        }
    }
}

// MARK: - Button Style

private struct FillInBlankButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Question Progress Dots

struct QuestionProgressDots: View {
    let totalQuestions: Int
    let currentIndex: Int
    let correctAnswers: Int

    @State private var appeared = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<totalQuestions, id: \.self) { index in
                    ZStack {
                        // Glow for current
                        if index == currentIndex {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.accentColor.opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 3,
                                        endRadius: 12
                                    )
                                )
                                .frame(width: 20, height: 20)
                        }

                        // Main dot
                        Circle()
                            .fill(dotGradient(for: index))
                            .frame(width: dotSize(for: index), height: dotSize(for: index))
                            .overlay(
                                Circle()
                                    .stroke(
                                        index == currentIndex ?
                                            LinearGradient(colors: [.accentColor, .accentColor.opacity(0.7)], startPoint: .top, endPoint: .bottom) :
                                            LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(
                                color: index == currentIndex ? .accentColor.opacity(0.3) : .clear,
                                radius: 4, y: 2
                            )

                        // Checkmark for completed
                        if index < currentIndex {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.02), value: appeared)
                    .animation(.spring(response: 0.3), value: currentIndex)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
        }
        .onAppear {
            appeared = true
        }
    }

    private func dotGradient(for index: Int) -> LinearGradient {
        if index < currentIndex {
            return LinearGradient(
                colors: [.accentColor, .accentColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if index == currentIndex {
            return LinearGradient(
                colors: [.accentColor.opacity(0.3), .accentColor.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemGray5), Color(.systemGray5).opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private func dotSize(for index: Int) -> CGFloat {
        index == currentIndex ? 12 : 10
    }
}

#Preview {
    NavigationStack {
        FillInBlankView(wordCount: 10, category: .all)
            .modelContainer(for: [Word.self, StudySession.self, UserSettings.self])
    }
}
