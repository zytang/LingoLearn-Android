//
//  LoadingView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct LoadingView: View {
    var message: String = "加载中..."
    var showProgress: Bool = true

    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            if showProgress {
                // Enhanced animated loading indicator
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.accentColor.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 25,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .opacity(glowOpacity)

                    // Outer pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.accentColor.opacity(0.25), .accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(pulseScale)

                    // Secondary rotating ring (opposite direction)
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-rotationAngle * 0.7))

                    // Main rotating gradient arc
                    Circle()
                        .trim(from: 0, to: 0.65)
                        .stroke(
                            AngularGradient(
                                colors: [.accentColor, .cyan, .accentColor.opacity(0.3)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotationAngle))
                        .shadow(color: .accentColor.opacity(0.4), radius: 4)

                    // Center bouncing dots with gradient
                    HStack(spacing: 7) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentColor, .cyan],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 9, height: 9)
                                .shadow(color: .accentColor.opacity(0.4), radius: 3)
                                .offset(y: isAnimating ? -6 : 6)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.15),
                                    value: isAnimating
                                )
                        }
                    }

                    // Sparkle decorations
                    ForEach(0..<4, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentColor, .cyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .offset(y: -45)
                            .rotationEffect(.degrees(Double(i) * 90 + sparkleRotation))
                            .opacity(glowOpacity * 0.6)
                    }
                }
            }

            // Enhanced message with icon
            VStack(spacing: 8) {
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary.opacity(0.8), .secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Progress hint
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.caption2)
                        .symbolEffect(.variableColor.iterative, options: .repeating, value: isAnimating)
                    Text("请稍候...")
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
                .opacity(appeared ? 1 : 0)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [.accentColor.opacity(0.03), .clear],
                center: .center,
                startRadius: 50,
                endRadius: 200
            )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
            isAnimating = true

            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
    }
}

/// A skeleton loading placeholder for list items with shimmer effect
struct SkeletonRow: View {
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 40, height: 40)
                .shimmer(offset: shimmerOffset)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 140, height: 16)
                    .shimmer(offset: shimmerOffset)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 12)
                    .shimmer(offset: shimmerOffset)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 50, height: 24)
                .shimmer(offset: shimmerOffset)
        }
        .padding(.vertical, 8)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .offset(x: offset)
                    .blur(radius: 5)
                }
                .mask(content)
            )
    }
}

extension View {
    func shimmer(offset: CGFloat) -> some View {
        modifier(ShimmerModifier(offset: offset))
    }
}

/// A loading overlay that can be placed on top of content
struct LoadingOverlay: View {
    let isLoading: Bool
    var message: String = "加载中..."

    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0

    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Custom spinner
                    ZStack {
                        // Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.2), .clear],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 35
                                )
                            )
                            .frame(width: 60, height: 60)
                            .opacity(glowOpacity)

                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .scaleEffect(pulseScale)

                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                AngularGradient(
                                    colors: [.white, .white.opacity(0.3)],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(rotationAngle))
                    }

                    VStack(spacing: 6) {
                        Text(message)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(.white.opacity(0.6))
                                    .frame(width: 4, height: 4)
                                    .opacity(glowOpacity)
                                    .animation(
                                        .easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.15),
                                        value: glowOpacity
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)

                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            }
        }
    }
}

#Preview("Loading View") {
    LoadingView(message: "正在准备测试...")
}

#Preview("Skeleton Rows") {
    List {
        ForEach(0..<5, id: \.self) { _ in
            SkeletonRow()
        }
    }
    .listStyle(.plain)
}

#Preview("Loading Overlay") {
    ZStack {
        Color.blue.ignoresSafeArea()
        Text("Content behind")
            .foregroundStyle(.white)
        LoadingOverlay(isLoading: true, message: "保存中...")
    }
}
