//
//  ListeningTestView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ListeningTestView: View {
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
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var hasPlayedAudio = false

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
                        VStack(spacing: 28) {
                            // Instructions badge
                            HStack(spacing: 6) {
                                Image(systemName: "ear.fill")
                                    .font(.caption)
                                Text("听发音，选择正确的单词")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: .orange.opacity(0.3), radius: 6, y: 3)
                            .padding(.top, 24)

                            // Audio control
                            AudioPlaybackButton(
                                hasPlayedAudio: hasPlayedAudio,
                                onPlay: {
                                    HapticManager.shared.impact()
                                    playWord(question.word.english)
                                }
                            )
                            .padding(.vertical, 16)

                            // Answer options with staggered animation
                            VStack(spacing: 14) {
                                ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
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
        .navigationTitle("听力题")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("退出") {
                    viewModel.stopTimer()
                    speechSynthesizer.stopSpeaking(at: .immediate)
                    dismiss()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            TestResultsView(
                sessionType: .listening,
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
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        .onChange(of: viewModel.currentQuestionIndex) { oldValue, newValue in
            hasPlayedAudio = false
            if let question = viewModel.currentQuestion, !answerSubmitted {
                // Auto-play on new question
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playWord(question.word.english)
                }
            }
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

    private func playWord(_ word: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4 // Slower for learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        speechSynthesizer.speak(utterance)
        hasPlayedAudio = true
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
                    viewModel.saveSession(modelContext: modelContext, sessionType: .listening)
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
            testType: .listening,
            timeLimit: timeLimit
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            viewModel.startTimer()

            // Auto-play first word
            if let question = viewModel.currentQuestion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playWord(question.word.english)
                }
            }
        }
    }
}

// MARK: - Audio Playback Button

struct AudioPlaybackButton: View {
    let hasPlayedAudio: Bool
    let onPlay: () -> Void

    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var waveRotation: Double = 0
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .opacity(glowOpacity)

                // Sound wave rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.4 - Double(i) * 0.1), .yellow.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: CGFloat(100 + i * 20), height: CGFloat(100 + i * 20))
                        .scaleEffect(pulseScale - CGFloat(i) * 0.1)
                        .opacity(isAnimating ? 0 : Double(3 - i) * 0.2)
                }

                // Inner background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.15), .yellow.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.2), .yellow.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 95, height: 95)

                // Main icon
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.4), radius: 8)
                    .symbolEffect(.pulse, options: .repeating.speed(0.5), value: isAnimating)
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            Button(action: {
                triggerPulse()
                onPlay()
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 32, height: 32)

                        Image(systemName: hasPlayedAudio ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.body)
                            .symbolEffect(.variableColor.iterative.reversing, options: .repeating, value: isAnimating)
                    }

                    Text(hasPlayedAudio ? "重新播放" : "播放发音")
                        .font(.headline)
                        .fontWeight(.semibold)

                    if !hasPlayedAudio {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                            .opacity(0.8)
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [.orange, .yellow.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(AudioButtonStyle())
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            startPulseAnimation()

            // Glow animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
            pulseScale = 1.3
            isAnimating = true
        }
    }

    private func triggerPulse() {
        pulseScale = 1.0
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startPulseAnimation()
        }
    }
}

// MARK: - Audio Button Style

private struct AudioButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        ListeningTestView(wordCount: 10, category: .all)
            .modelContainer(for: [Word.self, StudySession.self, UserSettings.self])
    }
}
