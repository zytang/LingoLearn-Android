//
//  EmptyStateView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var iconColor: Color = .secondary
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var secondaryActionTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    @State private var isAnimating = false
    @State private var hasAppeared = false
    @State private var iconRotation: Double = 0
    @State private var particleOpacity: Double = 0

    private var gradientColors: [Color] {
        [iconColor, iconColor.opacity(0.7)]
    }

    var body: some View {
        VStack(spacing: 28) {
            // Animated icon with gradient background and particles
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [iconColor.opacity(0.2), iconColor.opacity(0.02)],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                    .opacity(isAnimating ? 1 : 0.5)

                // Outer pulsing ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.3 : 0.8)

                // Middle ring
                Circle()
                    .stroke(iconColor.opacity(0.2), lineWidth: 1)
                    .frame(width: 135, height: 135)
                    .rotationEffect(.degrees(iconRotation))

                // Inner gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.15), iconColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.95)

                // Floating particles
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(iconColor.opacity(0.4))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: CGFloat.random(in: -60...60),
                            y: CGFloat.random(in: -60...60)
                        )
                        .opacity(particleOpacity * Double.random(in: 0.3...1.0))
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: particleOpacity
                        )
                }

                // Icon with gradient
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.bounce, value: hasAppeared)
            }
            .scaleEffect(hasAppeared ? 1 : 0.6)
            .opacity(hasAppeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    iconRotation = 360
                }
                withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                    particleOpacity = 1
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    hasAppeared = true
                }
            }

            // Title and description
            VStack(spacing: 10) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .offset(y: hasAppeared ? 0 : 20)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: hasAppeared)

            // Action buttons
            VStack(spacing: 12) {
                if let actionTitle = actionTitle, let action = action {
                    Button(action: {
                        HapticManager.shared.impact()
                        action()
                    }) {
                        HStack(spacing: 8) {
                            Text(actionTitle)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .shadow(color: iconColor.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(EmptyStateButtonStyle())
                }

                if let secondaryTitle = secondaryActionTitle, let secondaryAction = secondaryAction {
                    Button(action: {
                        HapticManager.shared.selection()
                        secondaryAction()
                    }) {
                        Text(secondaryTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(iconColor)
                    }
                }
            }
            .offset(y: hasAppeared ? 0 : 30)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: hasAppeared)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Button Style

private struct EmptyStateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview("With Action") {
    EmptyStateView(
        icon: "book.closed",
        title: "暂无单词",
        description: "添加一些单词到您的词汇表开始学习吧",
        iconColor: .blue,
        actionTitle: "添加单词",
        action: { }
    )
}

#Preview("Without Action") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "没有找到结果",
        description: "尝试调整搜索条件或筛选器",
        iconColor: .orange
    )
}

#Preview("Success State") {
    EmptyStateView(
        icon: "checkmark.circle.fill",
        title: "全部完成!",
        description: "您已完成今天的学习目标,明天继续加油",
        iconColor: .green
    )
}
