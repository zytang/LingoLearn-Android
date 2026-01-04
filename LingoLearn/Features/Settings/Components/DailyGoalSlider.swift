//
//  DailyGoalSlider.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct DailyGoalSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    @State private var animatedValue: Int = 0
    @State private var isDragging = false
    @State private var glowOpacity: Double = 0
    @State private var appeared = false
    @State private var pulseScale: CGFloat = 1.0

    private var difficultyLevel: DifficultyLevel {
        let percentage = Double(value - range.lowerBound) / Double(range.upperBound - range.lowerBound)
        if percentage < 0.33 {
            return .easy
        } else if percentage < 0.66 {
            return .medium
        } else {
            return .hard
        }
    }

    private enum DifficultyLevel {
        case easy, medium, hard

        var colors: [Color] {
            switch self {
            case .easy: return [.green, .mint]
            case .medium: return [.orange, .yellow]
            case .hard: return [.red, .orange]
            }
        }

        var color: Color {
            colors.first ?? .green
        }

        var icon: String {
            switch self {
            case .easy: return "leaf.fill"
            case .medium: return "flame.fill"
            case .hard: return "bolt.fill"
            }
        }

        var label: String {
            switch self {
            case .easy: return "轻松"
            case .medium: return "适中"
            case .hard: return "挑战"
            }
        }

        var motivationalMessage: String {
            switch self {
            case .easy: return "稳步前进"
            case .medium: return "保持节奏"
            case .hard: return "挑战自我"
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Current value display
            HStack(spacing: 16) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [difficultyLevel.color.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .opacity(glowOpacity)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: difficultyLevel.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: difficultyLevel.color.opacity(0.4), radius: 8, y: 4)

                    Image(systemName: difficultyLevel.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: value)
                }
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(value)")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentTransition(.numericText())
                        Text("个单词/天")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        // Difficulty badge
                        HStack(spacing: 4) {
                            Image(systemName: difficultyLevel.icon)
                                .font(.caption2)
                            Text(difficultyLevel.label)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: difficultyLevel.colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: difficultyLevel.color.opacity(0.3), radius: 3, y: 2)

                        // Time estimate
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("约\(value * 5)分钟")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    // Motivational message
                    Text(difficultyLevel.motivationalMessage)
                        .font(.caption)
                        .foregroundStyle(difficultyLevel.color.opacity(0.8))
                        .opacity(appeared ? 1 : 0)
                }

                Spacer()
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemBackground))

                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [difficultyLevel.color.opacity(0.12), difficultyLevel.colors.last?.opacity(0.06) ?? .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [difficultyLevel.color.opacity(0.3), difficultyLevel.colors.last?.opacity(0.15) ?? .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: difficultyLevel.color.opacity(0.1), radius: 10, y: 4)
            .animation(.easeInOut(duration: 0.2), value: difficultyLevel.color)

            // Slider with custom track
            VStack(spacing: 12) {
                // Custom slider track visualization
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 8)

                        // Progress track with gradient
                        let progress = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.15), value: value)

                        // Thumb indicator
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: difficultyLevel.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: isDragging ? 24 : 20, height: isDragging ? 24 : 20)
                            .shadow(color: difficultyLevel.color.opacity(0.4), radius: 4, y: 2)
                            .offset(x: geometry.size.width * progress - (isDragging ? 12 : 10))
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                    }
                }
                .frame(height: 24)

                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: { newValue in
                            let newIntValue = Int(newValue / Double(step)) * step
                            if newIntValue != value {
                                HapticManager.shared.impact()
                                value = newIntValue
                            }
                        }
                    ),
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: Double(step),
                    onEditingChanged: { editing in
                        isDragging = editing
                        if editing {
                            HapticManager.shared.impact()
                        }
                    }
                )
                .tint(.clear)
                .opacity(0.01)

                // Range labels with difficulty markers
                HStack {
                    DifficultyMarker(value: range.lowerBound, label: "轻松", color: .green, alignment: .leading)

                    Spacer()

                    DifficultyMarker(value: (range.lowerBound + range.upperBound) / 2, label: "适中", color: .orange, alignment: .center)

                    Spacer()

                    DifficultyMarker(value: range.upperBound, label: "挑战", color: .red, alignment: .trailing)
                }
            }
        }
        .onAppear {
            animatedValue = value
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }

            // Glow animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7
                pulseScale = 1.05
            }
        }
        .onChange(of: value) { _, _ in
            HapticManager.shared.impact()
        }
    }
}

// MARK: - Difficulty Marker

private struct DifficultyMarker: View {
    let value: Int
    let label: String
    let color: Color
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 3) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            HStack(spacing: 3) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 6)

                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    DailyGoalSlider(
        value: .constant(20),
        range: 10...100,
        step: 5
    )
    .padding()
}
