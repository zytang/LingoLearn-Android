//
//  StreakCard.swift
//  LingoLearn
//
//  Displays the current streak and longest streak
//

import SwiftUI

struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int

    @State private var showContent = false
    @State private var animatedStreak: Int = 0
    @State private var glowOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var recordBadgePulse = false

    private var isNewRecord: Bool {
        currentStreak > 0 && currentStreak >= longestStreak
    }

    private var streakLevelColors: [Color] {
        switch currentStreak {
        case 0:
            return [.gray, .gray.opacity(0.7)]
        case 1..<7:
            return [.orange, .yellow]
        case 7..<30:
            return [.red, .orange]
        case 30..<100:
            return [.purple, .pink]
        default:
            return [.blue, .cyan]
        }
    }

    private var streakLevelName: String {
        switch currentStreak {
        case 0:
            return "开始学习吧"
        case 1..<7:
            return "初学者"
        case 7..<30:
            return "坚持者"
        case 30..<100:
            return "学霸"
        default:
            return "传奇"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("连续学习")
                        .font(.headline)
                        .fontWeight(.semibold)

                    // Streak level badge
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text(streakLevelName)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: streakLevelColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: streakLevelColors.first?.opacity(0.4) ?? .clear, radius: 4, y: 2)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)

                    if isNewRecord && currentStreak > 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("新纪录!")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .orange.opacity(0.4), radius: 4, y: 2)
                        .scaleEffect(recordBadgePulse ? 1.05 : 1.0)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.5)
                    }
                }

                FlameStreakView(streakCount: currentStreak)
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : -20)

                HStack(spacing: 16) {
                    // Trophy with glow
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.yellow.opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 2,
                                        endRadius: 12
                                    )
                                )
                                .frame(width: 24, height: 24)
                                .opacity(glowOpacity)

                            Image(systemName: "trophy.fill")
                                .font(.caption)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }

                        Text("最长: \(longestStreak)天")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)

                    if currentStreak > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.caption)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            Text("继续保持!")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .opacity(showContent ? 1 : 0)
            }

            Spacer()

            // Motivational icon with sparkles
            if currentStreak > 0 {
                ZStack {
                    // Sparkle ring for high streaks
                    if currentStreak >= 7 {
                        ForEach(0..<6, id: \.self) { i in
                            Circle()
                                .fill(streakLevelColors.last ?? .orange)
                                .frame(width: 4, height: 4)
                                .offset(y: -30)
                                .rotationEffect(.degrees(Double(i) * 60 + sparkleRotation))
                                .opacity(glowOpacity * 0.6)
                        }
                    }

                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [streakLevelColors.first?.opacity(0.3) ?? .clear, .clear],
                                center: .center,
                                startRadius: 15,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .opacity(glowOpacity)

                    Image(systemName: streakIcon)
                        .font(.system(size: 36))
                        .foregroundStyle(streakIconGradient)
                        .symbolEffect(.pulse, options: .repeating.speed(0.5), value: showContent)
                        .shadow(color: streakLevelColors.first?.opacity(0.5) ?? .clear, radius: 8)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.5)
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [streakLevelColors.first?.opacity(0.08) ?? .clear, streakLevelColors.last?.opacity(0.04) ?? .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isNewRecord ?
                        LinearGradient(colors: [.orange.opacity(0.5), .red.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [streakLevelColors.first?.opacity(0.2) ?? .clear, streakLevelColors.last?.opacity(0.1) ?? .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isNewRecord ? 2 : 1
                )
        )
        .shadow(color: streakLevelColors.first?.opacity(0.15) ?? .clear, radius: 12, y: 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showContent = true
            }

            // Glow animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }

            // Sparkle rotation
            if currentStreak >= 7 {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    sparkleRotation = 360
                }
            }

            // Record badge pulse
            if isNewRecord && currentStreak > 1 {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.5)) {
                    recordBadgePulse = true
                }
            }
        }
    }

    private var streakIcon: String {
        switch currentStreak {
        case 1..<7:
            return "star.fill"
        case 7..<30:
            return "star.circle.fill"
        case 30..<100:
            return "crown.fill"
        default:
            return "sparkles"
        }
    }

    private var streakIconGradient: LinearGradient {
        switch currentStreak {
        case 1..<7:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        case 7..<30:
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        case 30..<100:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
        }
    }
}

#Preview {
    StreakCard(currentStreak: 7, longestStreak: 14)
        .padding()
}
