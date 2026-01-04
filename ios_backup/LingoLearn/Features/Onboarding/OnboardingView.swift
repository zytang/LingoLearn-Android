//
//  OnboardingView.swift
//  LingoLearn
//
//  Welcome onboarding flow for new users
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let secondaryColor: Color

    var gradientColors: [Color] {
        [color, secondaryColor]
    }
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var dailyGoal: Int = 20
    @State private var showContent = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "book.fill",
            title: "科学记忆",
            subtitle: "采用SM-2间隔重复算法，帮助你高效记忆单词，让学习事半功倍",
            color: .blue,
            secondaryColor: .cyan
        ),
        OnboardingPage(
            icon: "flame.fill",
            title: "坚持学习",
            subtitle: "每天坚持学习，保持学习连击，逐步建立英语词汇量",
            color: .orange,
            secondaryColor: .red
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "追踪进度",
            subtitle: "直观的图表展示你的学习成果，见证每一步成长",
            color: .green,
            secondaryColor: .mint
        ),
        OnboardingPage(
            icon: "star.fill",
            title: "解锁成就",
            subtitle: "完成挑战，解锁成就徽章，让学习更有趣味",
            color: .purple,
            secondaryColor: .pink
        )
    ]

    private var currentColor: Color {
        if currentPage < pages.count {
            return pages[currentPage].color
        }
        return .accentColor
    }

    private var currentGradient: [Color] {
        if currentPage < pages.count {
            return pages[currentPage].gradientColors
        }
        return [.accentColor, .accentColor.opacity(0.7)]
    }

    var body: some View {
        ZStack {
            // Animated background
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }

                    // Goal setting page
                    GoalSettingPage(dailyGoal: $dailyGoal)
                        .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Page indicators and button
                VStack(spacing: 24) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0...pages.count, id: \.self) { index in
                            Capsule()
                                .fill(
                                    index == currentPage ?
                                        LinearGradient(
                                            colors: currentGradient,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .frame(width: index == currentPage ? 28 : 8, height: 8)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground).opacity(0.8))
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
                    )

                    // Action button
                    Button(action: {
                        HapticManager.shared.impact()
                        if currentPage < pages.count {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(currentPage < pages.count ? "继续" : "开始学习")
                                .fontWeight(.semibold)

                            Image(systemName: currentPage < pages.count ? "arrow.right" : "sparkles")
                                .symbolEffect(.bounce, value: currentPage)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: currentGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: currentColor.opacity(0.4), radius: 12, y: 6)
                    }
                    .buttonStyle(OnboardingButtonStyle())

                    // Skip button (only on intro pages)
                    if currentPage < pages.count {
                        Button(action: {
                            HapticManager.shared.selection()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                currentPage = pages.count
                            }
                        }) {
                            Text("跳过")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            Color(.systemBackground)

            // Colored gradient blobs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [currentColor.opacity(0.15), currentColor.opacity(0)],
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: -100, y: -200)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [currentGradient.last?.opacity(0.1) ?? .clear, .clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 300)
        }
    }

    private func completeOnboarding() {
        HapticManager.shared.success()
        hasCompletedOnboarding = true
    }
}

// MARK: - Button Style

private struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var isAnimating = false
    @State private var ringRotation: Double = 0
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            // Animated icon with multiple rings
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.color.opacity(0.2), page.color.opacity(0)],
                            center: .center,
                            startRadius: 60,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)

                // Rotating ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [page.color.opacity(0.3), page.color.opacity(0.1), page.color.opacity(0.3)],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(ringRotation))

                // Outer pulsing circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.12), page.color.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(isAnimating ? 1.08 : 1.0)

                // Inner gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.25), page.secondaryColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                // Icon with gradient
                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.bounce, value: isActive)

                // Decorative floating dots
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(page.color.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .offset(
                            x: cos(Double(index) * .pi / 2 + ringRotation * 0.01) * 100,
                            y: sin(Double(index) * .pi / 2 + ringRotation * 0.01) * 100
                        )
                }
            }
            .scaleEffect(hasAppeared ? 1 : 0.7)
            .opacity(hasAppeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    hasAppeared = true
                }
            }

            // Text content
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 36)
            .offset(y: hasAppeared ? 0 : 30)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: hasAppeared)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Goal Setting Page

struct GoalSettingPage: View {
    @Binding var dailyGoal: Int
    @State private var hasAppeared = false
    @State private var ringProgress: Double = 0

    private let goalOptions = [10, 15, 20, 30, 50]

    private var estimatedMinutes: Int {
        dailyGoal * 2 // ~2 minutes per word
    }

    private var difficultyLabel: String {
        switch dailyGoal {
        case 10...15: return "轻松"
        case 20...30: return "适中"
        default: return "挑战"
        }
    }

    private var difficultyColor: Color {
        switch dailyGoal {
        case 10...15: return .green
        case 20...30: return .orange
        default: return .red
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Goal visualization
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0)],
                            center: .center,
                            startRadius: 40,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)

                // Progress ring background
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                    .frame(width: 160, height: 160)

                // Animated progress ring
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                // Inner circle
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 130, height: 130)
                    .shadow(color: .black.opacity(0.05), radius: 10)

                VStack(spacing: 2) {
                    Text("\(dailyGoal)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.numericText())

                    Text("个单词/天")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .scaleEffect(hasAppeared ? 1 : 0.7)
            .opacity(hasAppeared ? 1 : 0)

            // Title and subtitle
            VStack(spacing: 12) {
                Text("设定每日目标")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("每天学习多少个新单词？你可以随时在设置中修改")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 36)
            .offset(y: hasAppeared ? 0 : 20)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: hasAppeared)

            // Goal selector
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    ForEach(goalOptions, id: \.self) { goal in
                        GoalButton(
                            value: goal,
                            isSelected: dailyGoal == goal,
                            action: {
                                HapticManager.shared.selection()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    dailyGoal = goal
                                    ringProgress = Double(goal) / 50.0
                                }
                            }
                        )
                    }
                }

                // Info badges
                HStack(spacing: 16) {
                    InfoBadge(icon: "clock.fill", text: "约 \(estimatedMinutes) 分钟", color: .blue)
                    InfoBadge(icon: "flame.fill", text: difficultyLabel, color: difficultyColor)
                }
            }
            .padding(.horizontal, 24)
            .offset(y: hasAppeared ? 0 : 30)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: hasAppeared)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                hasAppeared = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3)) {
                ringProgress = Double(dailyGoal) / 50.0
            }
        }
    }
}

// MARK: - Info Badge

private struct InfoBadge: View {
    let icon: String
    let text: String
    let color: Color

    @State private var glowOpacity: Double = 0

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                // Subtle glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 10
                        )
                    )
                    .frame(width: 18, height: 18)
                    .opacity(glowOpacity)

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.12), color.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
}

// MARK: - Goal Button

struct GoalButton: View {
    let value: Int
    let isSelected: Bool
    let action: () -> Void

    @State private var glowOpacity: Double = 0

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow for selected
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.accentColor.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 45
                            )
                        )
                        .frame(width: 70, height: 70)
                        .opacity(glowOpacity)
                }

                VStack(spacing: 4) {
                    Text("\(value)")
                        .font(.title3)
                        .fontWeight(isSelected ? .bold : .medium)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .contentTransition(.numericText())
                }
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            isSelected ?
                                LinearGradient(
                                    colors: [.accentColor, .cyan.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color(.systemGray6), Color(.systemGray5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ?
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1
                        )
                )
            }
            .shadow(color: isSelected ? Color.accentColor.opacity(0.4) : .black.opacity(0.05), radius: isSelected ? 10 : 4, y: isSelected ? 5 : 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            } else {
                glowOpacity = 0
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
