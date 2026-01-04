//
//  QuickActionButton.swift
//  LingoLearn
//
//  Reusable quick action button for home screen
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void

    @State private var isPressed = false
    @State private var iconPulse: Bool = false

    var body: some View {
        Button(action: {
            HapticManager.shared.impact()
            action()
        }) {
            HStack(spacing: 16) {
                // Icon container with gradient background
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 30
                            )
                        )
                        .frame(width: 54, height: 54)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.15), color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse, value: iconPulse)
                }
                .shadow(color: color.opacity(0.25), radius: 6, y: 3)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient(
                                        colors: [color, color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Enhanced chevron
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 28, height: 28)

                    Image(systemName: "chevron.right")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .font(.caption.weight(.bold))
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))

                    // Subtle gradient accent
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.03), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            // Subtle pulse on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                iconPulse = true
            }
        }
    }
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        QuickActionButton(
            icon: "book.fill",
            title: "开始学习",
            subtitle: "学习新单词",
            color: .blue
        ) {
            print("Tapped learning")
        }

        QuickActionButton(
            icon: "arrow.clockwise",
            title: "快速复习",
            subtitle: "复习已学单词",
            color: .purple
        ) {
            print("Tapped review")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
