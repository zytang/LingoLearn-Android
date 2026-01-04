//
//  WrongAnswerAnimation.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

struct WrongAnswerAnimation: View {
    @State private var attempts: Int = 0
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 1
    @State private var crossRotation: Double = -45
    @State private var pulseScale: CGFloat = 1.0
    @State private var cracksOpacity: Double = 0

    private let gradientColors: [Color] = [.red, .orange]

    var body: some View {
        ZStack {
            // Pulse ring effect
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.red.opacity(0.4), .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 160, height: 160)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            // Crack lines radiating outward
            ForEach(0..<6, id: \.self) { index in
                CrackLine()
                    .stroke(
                        LinearGradient(
                            colors: [.red.opacity(0.6), .red.opacity(0)],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 8, height: 35)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(index) * 60))
                    .opacity(cracksOpacity)
            }

            // Glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.red.opacity(0.3), .red.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(scale * pulseScale)

            // Inner gradient circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red.opacity(0.25), .orange.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(scale)

            // X mark icon with gradient
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(crossRotation))
                .symbolEffect(.bounce, value: attempts > 0)
        }
        .modifier(ShakeEffect(animatableData: CGFloat(attempts)))
        .opacity(opacity)
        .onAppear {
            // Main animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                crossRotation = 0
            }

            // Ring expansion
            withAnimation(.easeOut(duration: 0.5)) {
                ringScale = 1.4
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                ringOpacity = 0
            }

            // Crack lines
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                cracksOpacity = 1
            }

            withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                cracksOpacity = 0
            }

            // Shake animation
            withAnimation(.default.delay(0.1)) {
                attempts += 1
            }

            // Pulse effect
            withAnimation(.easeInOut(duration: 0.15).repeatCount(2, autoreverses: true).delay(0.2)) {
                pulseScale = 1.1
            }

            // Haptic feedback
            HapticManager.shared.error()
        }
    }
}

// MARK: - Crack Line Shape

private struct CrackLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - 2, y: rect.midY + 5))
        path.addLine(to: CGPoint(x: rect.midX + 2, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX - 1, y: rect.minY + 5))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        WrongAnswerAnimation()
    }
}
