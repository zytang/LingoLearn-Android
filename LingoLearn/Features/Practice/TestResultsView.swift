//
//  TestResultsView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct TestResultsView: View {
    let sessionType: SessionType
    let correctAnswers: Int
    let wrongAnswers: [WrongAnswer]
    let totalQuestions: Int
    let duration: TimeInterval

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWrongWordReview = false
    @State private var animatedAccuracy: Double = 0
    @State private var showStats = false
    @State private var showWrongAnswers = false
    @State private var iconScale: CGFloat = 0.5
    @State private var showConfetti = false

    private var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }

    private var accuracyColor: Color {
        if accuracy >= 90 {
            return .green
        } else if accuracy >= 70 {
            return .orange
        } else {
            return .red
        }
    }

    private var accuracyGradient: [Color] {
        if accuracy >= 90 {
            return [.green, .mint]
        } else if accuracy >= 70 {
            return [.orange, .yellow]
        } else {
            return [.red, .orange]
        }
    }

    private var performanceMessage: String {
        if accuracy >= 90 {
            return "太棒了！继续保持！"
        } else if accuracy >= 70 {
            return "做得不错，再接再厉！"
        } else if accuracy >= 50 {
            return "还需努力，加油！"
        } else {
            return "多多练习，相信自己！"
        }
    }

    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [accuracyColor.opacity(0.3), accuracyColor.opacity(0)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(iconScale)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accuracyColor.opacity(0.15), accuracyColor.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .scaleEffect(iconScale)

                        Image(systemName: accuracy >= 90 ? "trophy.fill" : accuracy >= 70 ? "star.fill" : "hand.thumbsup.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: accuracyGradient,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(iconScale)
                            .symbolEffect(.bounce, value: iconScale == 1.0)
                    }

                    VStack(spacing: 4) {
                        Text(accuracy >= 90 ? "优秀!" : accuracy >= 70 ? "很好!" : "继续加油!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(performanceMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .opacity(iconScale == 1.0 ? 1 : 0)
                }
                .padding(.top, 32)

                // Accuracy ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 18)
                        .frame(width: 200, height: 200)

                    // Gradient progress ring
                    Circle()
                        .trim(from: 0, to: animatedAccuracy / 100)
                        .stroke(
                            AngularGradient(
                                colors: accuracyGradient + [accuracyGradient.first ?? .green],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360 * animatedAccuracy / 100)
                            ),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: accuracyColor.opacity(0.3), radius: 8, y: 4)

                    // Glow effect for high accuracy
                    if animatedAccuracy >= 80 {
                        Circle()
                            .trim(from: 0, to: animatedAccuracy / 100)
                            .stroke(
                                accuracyColor.opacity(0.4),
                                style: StrokeStyle(lineWidth: 22, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: 8)
                    }

                    // End cap
                    if animatedAccuracy > 5 {
                        Circle()
                            .fill(accuracyGradient.last ?? .green)
                            .frame(width: 18, height: 18)
                            .offset(y: -100)
                            .rotationEffect(.degrees(360 * animatedAccuracy / 100 - 90))
                            .shadow(color: accuracyColor.opacity(0.5), radius: 4)
                    }

                    VStack(spacing: 4) {
                        Text("\(Int(animatedAccuracy))%")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: accuracyGradient,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentTransition(.numericText())

                        Text("正确率")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Stats cards
                VStack(spacing: 16) {
                    ResultStatCard(
                        icon: "clock.fill",
                        title: "用时",
                        value: formattedDuration,
                        color: .blue
                    )

                    ResultStatCard(
                        icon: "book.fill",
                        title: "题目总数",
                        value: "\(totalQuestions)",
                        color: .purple
                    )

                    HStack(spacing: 16) {
                        ResultStatCard(
                            icon: "checkmark.circle.fill",
                            title: "正确",
                            value: "\(correctAnswers)",
                            color: .green
                        )

                        ResultStatCard(
                            icon: "xmark.circle.fill",
                            title: "错误",
                            value: "\(wrongAnswers.count)",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal)
                .opacity(showStats ? 1 : 0)
                .offset(y: showStats ? 0 : 20)

                // Wrong answers section
                if !wrongAnswers.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange.opacity(0.15), .red.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)

                                Image(systemName: "exclamationmark.bubble.fill")
                                    .font(.body)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("错题回顾")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("共 \(wrongAnswers.count) 题需要加强")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach(Array(wrongAnswers.enumerated()), id: \.offset) { index, wrongAnswer in
                                WrongAnswerCard(
                                    number: index + 1,
                                    wrongAnswer: wrongAnswer,
                                    sessionType: sessionType
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .opacity(showWrongAnswers ? 1 : 0)
                    .offset(y: showWrongAnswers ? 0 : 20)
                }

                // Action buttons
                VStack(spacing: 14) {
                    if !wrongAnswers.isEmpty {
                        NavigationLink(destination: WrongWordReviewView(wrongWords: wrongAnswers.map { $0.word })) {
                            HStack(spacing: 10) {
                                Image(systemName: "book.circle.fill")
                                    .font(.title3)
                                Text("复习错题")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(wrongAnswers.count)题")
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
                        }
                        .buttonStyle(ResultButtonStyle())
                    }

                    Button(action: {
                        HapticManager.shared.impact()
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.fill")
                                .font(.title3)
                            Text("返回主页")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .accentColor.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(ResultButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                .opacity(showStats ? 1 : 0)
            }
        }
        .confetti(isActive: $showConfetti)
        .navigationTitle("测试结果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            playEntryAnimation()
        }
    }

    private func playEntryAnimation() {
        // Icon animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            iconScale = 1.0
        }

        // Accuracy ring animation
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            animatedAccuracy = accuracy
        }

        // Haptic feedback based on performance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if accuracy >= 90 {
                HapticManager.shared.success()
                showConfetti = true
            } else if accuracy >= 70 {
                HapticManager.shared.success()
            } else {
                HapticManager.shared.warning()
            }
        }

        // Stats animation
        withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
            showStats = true
        }

        // Wrong answers animation
        withAnimation(.easeOut(duration: 0.4).delay(1.2)) {
            showWrongAnswers = true
        }
    }
}

struct ResultStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    @State private var appeared = false
    @State private var glowOpacity: Double = 0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)
                    .opacity(glowOpacity)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.pulse.byLayer, options: .speed(0.5), value: appeared)
            }
            .scaleEffect(appeared ? 1 : 0.8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.08), color.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Inner highlight
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.08), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.2), color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.1), radius: 6, y: 3)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
                glowOpacity = 1.0
            }
        }
    }
}

struct WrongAnswerCard: View {
    let number: Int
    let wrongAnswer: WrongAnswer
    let sessionType: SessionType

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Number badge
                Text("\(number)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .red.opacity(0.3), radius: 3, y: 2)

                Spacer()

                // Needs review badge
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text("需复习")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
            }

            // Show based on test type
            if sessionType == .multipleChoice {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(wrongAnswer.word.english)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(wrongAnswer.word.phonetic)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("你选择了: \(wrongAnswer.userAnswer)")
                            .font(.body)
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("正确答案: \(wrongAnswer.correctAnswer)")
                            .font(.body)
                            .foregroundStyle(.green)
                    }
                }
            } else if sessionType == .fillInBlank {
                VStack(alignment: .leading, spacing: 8) {
                    Text(wrongAnswer.word.chinese)
                        .font(.title3)
                        .fontWeight(.semibold)

                    if !wrongAnswer.userAnswer.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                            Text("你填写了: \(wrongAnswer.userAnswer)")
                                .font(.body)
                                .foregroundStyle(.red)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("正确答案: \(wrongAnswer.correctAnswer)")
                            .font(.body)
                            .foregroundStyle(.green)

                        Text("[\(wrongAnswer.word.phonetic)]")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if sessionType == .listening {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "headphones.circle.fill")
                            .foregroundStyle(.orange)
                        Text("听力题")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("你选择了: \(wrongAnswer.userAnswer)")
                            .font(.body)
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("正确答案: \(wrongAnswer.correctAnswer)")
                            .font(.body)
                            .foregroundStyle(.green)

                        Text("[\(wrongAnswer.word.phonetic)]")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(wrongAnswer.word.chinese)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }

            // Example sentence
            if !wrongAnswer.word.exampleSentence.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.caption2)
                        Text("例句")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.tertiary)

                    Text(wrongAnswer.word.exampleSentence)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)

                    Text(wrongAnswer.word.exampleTranslation)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 6)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.06), .orange.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Top highlight
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.06), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [.red.opacity(0.25), .orange.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .red.opacity(0.08), radius: 6, y: 3)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Result Button Style

private struct ResultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        TestResultsView(
            sessionType: .multipleChoice,
            correctAnswers: 8,
            wrongAnswers: [],
            totalQuestions: 10,
            duration: 125.5
        )
    }
}
