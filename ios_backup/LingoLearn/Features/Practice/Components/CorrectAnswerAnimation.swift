//
//  CorrectAnswerAnimation.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct CorrectAnswerAnimation: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 1
    @State private var checkmarkOffset: CGFloat = 20
    @State private var sparkleRotation: Double = 0
    @State private var sparkleScale: CGFloat = 0

    private let gradientColors: [Color] = [.green, .mint]

    var body: some View {
        ZStack {
            // Outer expanding ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.green.opacity(0.5), .mint.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 160, height: 160)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            // Sparkle rays
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .green.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4, height: 25)
                    .offset(y: -85)
                    .rotationEffect(.degrees(Double(index) * 45 + sparkleRotation))
                    .scaleEffect(sparkleScale)
            }

            // Glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.green.opacity(0.3), .green.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(scale)

            // Inner gradient circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.25), .mint.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(scale)

            // Checkmark icon with gradient
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(scale)
                .offset(y: checkmarkOffset)
                .symbolEffect(.bounce, value: scale == 1.0)

            // Floating particles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(.green.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(
                        x: cos(Double(index) * .pi / 3) * 70 * sparkleScale,
                        y: sin(Double(index) * .pi / 3) * 70 * sparkleScale - 20 * sparkleScale
                    )
                    .scaleEffect(sparkleScale)
                    .opacity(Double(sparkleScale))
            }
        }
        .opacity(opacity)
        .onAppear {
            // Main animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                checkmarkOffset = 0
            }

            // Ring expansion
            withAnimation(.easeOut(duration: 0.6)) {
                ringScale = 1.3
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                ringOpacity = 0
            }

            // Sparkle animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                sparkleScale = 1.0
            }

            withAnimation(.linear(duration: 1.5).delay(0.2)) {
                sparkleRotation = 45
            }

            // Haptic feedback
            HapticManager.shared.success()
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        CorrectAnswerAnimation()
    }
}
