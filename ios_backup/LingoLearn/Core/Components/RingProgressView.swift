//
//  RingProgressView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct RingProgressView: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let gradientColors: [Color]
    let size: CGFloat
    var showPercentage: Bool = true
    var showGlow: Bool = true

    @State private var animatedProgress: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var centerPulse: CGFloat = 1.0
    @State private var completionBounce = false

    init(progress: Double, lineWidth: CGFloat = 20, gradientColors: [Color] = [.blue, .purple], size: CGFloat = 150, showPercentage: Bool = true, showGlow: Bool = true) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
        self.size = size
        self.showPercentage = showPercentage
        self.showGlow = showGlow
    }

    private var isComplete: Bool {
        animatedProgress >= 1.0
    }

    private var primaryColor: Color {
        gradientColors.first ?? .blue
    }

    private var secondaryColor: Color {
        gradientColors.last ?? .purple
    }

    var body: some View {
        ZStack {
            // Inner decorative ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [primaryColor.opacity(0.05), secondaryColor.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth * 0.5
                )
                .frame(width: size - lineWidth * 2.5, height: size - lineWidth * 2.5)

            // Background circle with subtle gradient
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )

            // Glow effect for high progress
            if showGlow && animatedProgress >= 0.7 {
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gradientColors),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * animatedProgress)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth + 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 12)
                    .opacity(glowOpacity * 0.4)
            }

            // Progress circle with enhanced gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors + [gradientColors.first ?? .blue]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: primaryColor.opacity(0.35), radius: 6, y: 3)

            // End cap with enhanced glow
            if animatedProgress > 0.05 {
                ZStack {
                    // Glow ring around end cap
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [secondaryColor.opacity(0.4), .clear],
                                center: .center,
                                startRadius: lineWidth * 0.3,
                                endRadius: lineWidth
                            )
                        )
                        .frame(width: lineWidth * 2, height: lineWidth * 2)
                        .offset(y: -size / 2 + lineWidth / 2)
                        .rotationEffect(.degrees(360 * animatedProgress - 90))
                        .opacity(glowOpacity)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [secondaryColor, secondaryColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: lineWidth * 1.1, height: lineWidth * 1.1)
                        .offset(y: -size / 2 + lineWidth / 2)
                        .rotationEffect(.degrees(360 * animatedProgress - 90))
                        .shadow(color: secondaryColor.opacity(0.6), radius: 5)
                }
            }

            // Sparkle ring for completion
            if isComplete {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 5, height: 5)
                        .offset(y: -(size / 2) - 8)
                        .rotationEffect(.degrees(Double(i) * 45 + sparkleRotation))
                        .opacity(glowOpacity * 0.7)
                }
            }

            // Center content with enhanced styling
            if showPercentage {
                VStack(spacing: size * 0.02) {
                    // Percentage display
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            isComplete ?
                                LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [.primary, .primary.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        )
                        .contentTransition(.numericText())
                        .scaleEffect(centerPulse)

                    if isComplete {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: size * 0.09))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .symbolEffect(.bounce, value: completionBounce)
                            Text("完成!")
                                .font(.system(size: size * 0.1, weight: .semibold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("完成")
                            .font(.system(size: size * 0.1, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
            if progress >= 0.7 {
                startGlowAnimation()
            }
            if progress >= 1.0 {
                startCompletionAnimations()
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                animatedProgress = newValue
            }
            if newValue >= 0.7 && oldValue < 0.7 {
                startGlowAnimation()
            } else if newValue < 0.7 {
                glowOpacity = 0
            }

            if newValue >= 1.0 && oldValue < 1.0 {
                startCompletionAnimations()
                HapticManager.shared.success()
            }
        }
    }

    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }
    }

    private func startCompletionAnimations() {
        // Sparkle rotation
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // Center pulse
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            centerPulse = 1.05
        }

        // Completion bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completionBounce = true
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        RingProgressView(progress: 0.65)
        RingProgressView(progress: 0.30, gradientColors: [.green, .blue])
        RingProgressView(progress: 0.90, gradientColors: [.orange, .red])
    }
}
