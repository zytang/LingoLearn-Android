//
//  AchievementWall.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct AchievementWall: View {
    let unlockedAchievements: [String]
    let onAchievementTap: (Achievement) -> Void

    @State private var selectedAchievement: Achievement?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Achievement.all) { achievement in
                AchievementBadge(
                    achievement: achievement,
                    isUnlocked: unlockedAchievements.contains(achievement.id)
                )
                .onTapGesture {
                    HapticManager.shared.selection()
                    selectedAchievement = achievement
                }
            }
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(
                achievement: achievement,
                isUnlocked: unlockedAchievements.contains(achievement.id)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool

    @State private var isAnimating = false
    @State private var glowOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -50

    private var achievementColor: Color {
        if achievement.iconName.contains("flame") {
            return .orange
        } else if achievement.iconName.contains("star") {
            return .yellow
        } else if achievement.iconName.contains("checkmark") || achievement.iconName.contains("seal") {
            return .green
        } else if achievement.iconName.contains("moon") {
            return .purple
        } else if achievement.iconName.contains("sunrise") {
            return .pink
        } else if achievement.iconName.contains("100") || achievement.iconName.contains("circle") {
            return .blue
        } else {
            return .accentColor
        }
    }

    private var gradientColors: [Color] {
        [achievementColor, achievementColor.opacity(0.7)]
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow for unlocked
                if isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [achievementColor.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 15,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .opacity(glowOpacity)
                }

                // Background circle
                Circle()
                    .fill(
                        isUnlocked ?
                            LinearGradient(
                                colors: [achievementColor.opacity(0.2), achievementColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(.systemGray5), Color(.systemGray6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                isUnlocked ?
                                    LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: 2
                            )
                    )

                if isUnlocked {
                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.bounce, value: isAnimating)

                    // Shimmer effect
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .offset(x: shimmerOffset)
                        .mask(
                            Circle()
                                .frame(width: 60, height: 60)
                        )
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }

            Text(achievement.title)
                .font(.caption2)
                .fontWeight(isUnlocked ? .medium : .regular)
                .multilineTextAlignment(.center)
                .foregroundStyle(isUnlocked ? .primary : .tertiary)
                .lineLimit(2)
        }
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isAnimating)
        .onAppear {
            if isUnlocked {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.8
                }

                // Shimmer animation
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(3)) {
                        shimmerOffset = 50
                    }
                }
            }
        }
    }
}

struct AchievementDetailSheet: View {
    let achievement: Achievement
    let isUnlocked: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var iconScale: CGFloat = 0.5
    @State private var showDetails = false
    @State private var ringRotation: Double = 0
    @State private var glowPulse: Double = 0

    private var achievementColor: Color {
        if achievement.iconName.contains("flame") {
            return .orange
        } else if achievement.iconName.contains("star") {
            return .yellow
        } else if achievement.iconName.contains("checkmark") || achievement.iconName.contains("seal") {
            return .green
        } else if achievement.iconName.contains("moon") {
            return .purple
        } else if achievement.iconName.contains("sunrise") {
            return .pink
        } else if achievement.iconName.contains("100") || achievement.iconName.contains("circle") {
            return .blue
        } else {
            return .accentColor
        }
    }

    private var gradientColors: [Color] {
        [achievementColor, achievementColor.opacity(0.7)]
    }

    var body: some View {
        VStack(spacing: 24) {
            // Badge with enhanced effects
            ZStack {
                // Outer rotating ring for unlocked
                if isUnlocked {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: gradientColors + [gradientColors.first ?? .accentColor],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(ringRotation))
                        .opacity(0.5)
                }

                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isUnlocked
                                ? [achievementColor.opacity(0.3 + glowPulse * 0.2), achievementColor.opacity(0.1), .clear]
                                : [Color.gray.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                // Inner circle
                Circle()
                    .fill(
                        isUnlocked ?
                            LinearGradient(
                                colors: [achievementColor.opacity(0.2), achievementColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(.systemGray5), Color(.systemGray6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                isUnlocked ?
                                    LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: 3
                            )
                    )

                if isUnlocked {
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.bounce, value: iconScale == 1.0)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                }
            }
            .scaleEffect(iconScale)

            VStack(spacing: 14) {
                Text(achievement.title)
                    .font(.title2.bold())
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if isUnlocked {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("已解锁")
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.15), Color.mint.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("继续努力解锁此成就")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
            }
            .opacity(showDetails ? 1 : 0)
            .offset(y: showDetails ? 0 : 20)

            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                showDetails = true
            }

            if isUnlocked {
                HapticManager.shared.success()

                // Ring rotation
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }

                // Glow pulse
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = 1.0
                }
            }
        }
    }
}

#Preview {
    AchievementWall(
        unlockedAchievements: ["first_word", "streak_7"],
        onAchievementTap: { _ in }
    )
    .padding()
}
