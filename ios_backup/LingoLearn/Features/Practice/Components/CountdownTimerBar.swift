//
//  CountdownTimerBar.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct CountdownTimerBar: View {
    let timeRemaining: Double
    let totalTime: Double
    @State private var shouldPulse = false
    @State private var glowOpacity: Double = 0
    @State private var lastWarningTime: Int = -1
    @State private var shimmerOffset: CGFloat = -100

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return timeRemaining / totalTime
    }

    private var barColors: [Color] {
        if progress > 0.5 {
            return [.green, .mint]
        } else if progress > 0.2 {
            return [.orange, .yellow]
        } else {
            return [.red, .orange]
        }
    }

    private var barColor: Color {
        barColors.first ?? .green
    }

    private var barGradient: LinearGradient {
        LinearGradient(
            colors: barColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background with subtle pattern
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Progress bar with gradient
                    RoundedRectangle(cornerRadius: 6)
                        .fill(barGradient)
                        .frame(width: max(0, geometry.size.width * progress))
                        .shadow(color: barColor.opacity(0.4), radius: 4, y: 2)
                        .animation(.linear(duration: 0.1), value: progress)

                    // Shimmer effect
                    if progress > 0.3 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 40)
                            .offset(x: shimmerOffset)
                            .mask(
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: max(0, geometry.size.width * progress))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            )
                    }

                    // Glow effect when low
                    if progress <= 0.2 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geometry.size.width * progress))
                            .blur(radius: 6)
                            .opacity(glowOpacity)
                    }

                    // End cap indicator
                    if progress > 0.05 {
                        Circle()
                            .fill(barColors.last ?? .white)
                            .frame(width: 10, height: 10)
                            .shadow(color: barColor.opacity(0.5), radius: 3)
                            .offset(x: max(0, geometry.size.width * progress - 5))
                    }
                }
            }
            .frame(height: 10)
            .scaleEffect(shouldPulse ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: shouldPulse)

            // Time display when low
            if timeRemaining <= 5 && timeRemaining > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(Int(timeRemaining))秒")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: barColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(barColor.opacity(0.15))
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Start shimmer animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 300
            }
        }
        .onChange(of: timeRemaining) { oldValue, newValue in
            // Pulse and haptic on low time
            if newValue <= 3 && newValue > 0 {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    shouldPulse = true
                    glowOpacity = 0.7
                }

                // Haptic on each second countdown
                let currentSecond = Int(newValue)
                if currentSecond != lastWarningTime && currentSecond <= 3 {
                    lastWarningTime = currentSecond
                    HapticManager.shared.warning()
                }
            } else {
                shouldPulse = false
                glowOpacity = 0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CountdownTimerBar(timeRemaining: 15, totalTime: 15)
        CountdownTimerBar(timeRemaining: 7, totalTime: 15)
        CountdownTimerBar(timeRemaining: 2, totalTime: 15)
    }
    .padding()
}
