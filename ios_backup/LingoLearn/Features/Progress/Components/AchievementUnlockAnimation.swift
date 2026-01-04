//
//  AchievementUnlockAnimation.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct AchievementUnlockAnimation: View {
    let achievement: Achievement
    @Binding var isPresented: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -15
    @State private var confettiActive: Bool = false
    @State private var glowOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var innerRingRotation: Double = 0
    @State private var outerRingRotation: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var starburstScale: CGFloat = 0
    @State private var backgroundBlur: Double = 0

    private var achievementColor: Color {
        // Color based on achievement icon/id
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
        ZStack {
            // Dimmed background with blur
            Color.black.opacity(0.6 * backgroundBlur)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Radial light rays
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [achievementColor.opacity(0.3), achievementColor.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 20, height: 300)
                    .offset(y: -150)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(glowOpacity * 0.5)
                    .scaleEffect(starburstScale)
            }

            // Achievement card
            VStack(spacing: 24) {
                // Badge icon with enhanced glow effect
                ZStack {
                    // Starburst background
                    ForEach(0..<12, id: \.self) { index in
                        Capsule()
                            .fill(achievementColor.opacity(0.15))
                            .frame(width: 4, height: 30)
                            .offset(y: -80)
                            .rotationEffect(.degrees(Double(index) * 30 + outerRingRotation * 0.5))
                    }
                    .scaleEffect(starburstScale)

                    // Outer rotating ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [achievementColor.opacity(0.5), achievementColor.opacity(0.1), achievementColor.opacity(0.5)],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(outerRingRotation))
                        .opacity(glowOpacity)

                    // Middle pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(glowOpacity)

                    // Inner rotating decorative ring
                    Circle()
                        .stroke(achievementColor.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(innerRingRotation))
                        .opacity(glowOpacity)

                    // Glow gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [achievementColor.opacity(0.4), achievementColor.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 150, height: 150)

                    // Inner circle background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [achievementColor.opacity(0.2), achievementColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    // Icon with gradient
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.bounce, value: scale == 1.0)

                    // Shimmer effect
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .offset(x: shimmerOffset)
                        .mask(
                            Circle()
                                .frame(width: 100, height: 100)
                        )
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))

                VStack(spacing: 12) {
                    // Unlocked badge
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                        Text("解锁成就!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                    .foregroundStyle(achievementColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(achievementColor.opacity(0.15))
                    .clipShape(Capsule())

                    Text(achievement.title)
                        .font(.title.bold())
                        .foregroundStyle(.primary)

                    Text(achievement.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
                .opacity(opacity)

                Button(action: {
                    HapticManager.shared.impact()
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .symbolEffect(.pulse, value: opacity == 1)
                        Text("太棒了!")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: achievementColor.opacity(0.4), radius: 12, y: 6)
                }
                .buttonStyle(AchievementButtonStyle())
                .padding(.top, 8)
                .opacity(opacity)
            }
            .padding(32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(.systemBackground))

                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [achievementColor.opacity(0.05), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .shadow(color: achievementColor.opacity(0.2), radius: 30, y: 10)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 5)
            )
            .padding(32)
            .scaleEffect(backgroundBlur)

            // Enhanced confetti
            ConfettiView(isActive: $confettiActive, duration: 3.5, intensity: .intense)
        }
        .onAppear {
            playAnimation()
        }
    }

    private func playAnimation() {
        // Haptic feedback
        HapticManager.shared.success()

        // Background fade in
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundBlur = 1.0
        }

        // Icon animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
        }

        // Starburst animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
            starburstScale = 1.0
        }

        // Glow animation
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            glowOpacity = 1.0
        }

        // Ring pulsing
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
            ringScale = 1.15
        }

        // Ring rotations
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            outerRingRotation = 360
        }

        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            innerRingRotation = -360
        }

        // Content fade in
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            opacity = 1.0
        }

        // Shimmer effect
        withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
            shimmerOffset = 200
        }

        // Repeat shimmer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            shimmerOffset = -200
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false).delay(0.5)) {
                shimmerOffset = 200
            }
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            confettiActive = true
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
            glowOpacity = 0
            starburstScale = 0
            backgroundBlur = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// MARK: - Button Style

private struct AchievementButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    AchievementUnlockAnimation(
        achievement: Achievement.all[0],
        isPresented: .constant(true)
    )
}
