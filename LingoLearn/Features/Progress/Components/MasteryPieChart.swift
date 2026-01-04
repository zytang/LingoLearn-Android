//
//  MasteryPieChart.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import Charts

struct MasteryPieChart: View {
    let newCount: Int
    let learningCount: Int
    let reviewingCount: Int
    let masteredCount: Int

    @State private var animationProgress: Double = 0
    @State private var selectedSegment: MasterySegment?
    @State private var ringPulse: CGFloat = 1.0

    fileprivate enum MasterySegment: String, CaseIterable {
        case new = "new"
        case learning = "learning"
        case reviewing = "reviewing"
        case mastered = "mastered"

        var label: String {
            switch self {
            case .new: return "新词"
            case .learning: return "学习中"
            case .reviewing: return "复习中"
            case .mastered: return "已掌握"
            }
        }

        var icon: String {
            switch self {
            case .new: return "sparkles"
            case .learning: return "book.fill"
            case .reviewing: return "arrow.clockwise"
            case .mastered: return "checkmark.seal.fill"
            }
        }

        var colors: [Color] {
            switch self {
            case .new: return [.gray, .gray.opacity(0.7)]
            case .learning: return [.orange, .yellow]
            case .reviewing: return [.blue, .cyan]
            case .mastered: return [.green, .mint]
            }
        }
    }

    private var total: Int {
        newCount + learningCount + reviewingCount + masteredCount
    }

    private var masteredPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(masteredCount) / Double(total) * 100
    }

    private var animatedNewCount: Int {
        Int(Double(newCount) * animationProgress)
    }

    private var animatedLearningCount: Int {
        Int(Double(learningCount) * animationProgress)
    }

    private var animatedReviewingCount: Int {
        Int(Double(reviewingCount) * animationProgress)
    }

    private var animatedMasteredCount: Int {
        Int(Double(masteredCount) * animationProgress)
    }

    private func count(for segment: MasterySegment) -> Int {
        switch segment {
        case .new: return newCount
        case .learning: return learningCount
        case .reviewing: return reviewingCount
        case .mastered: return masteredCount
        }
    }

    var body: some View {
        if total == 0 {
            // Enhanced empty state
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(.systemGray5), Color(.systemGray6)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(.systemGray4), Color(.systemGray5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )

                VStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.secondary, .secondary.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("暂无数据")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack(spacing: 16) {
                ZStack {
                    Chart {
                        if newCount > 0 {
                            SectorMark(
                                angle: .value("Count", animatedNewCount),
                                innerRadius: .ratio(0.55),
                                outerRadius: selectedSegment == .new ? .ratio(1.0) : .ratio(0.95),
                                angularInset: 2
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: MasterySegment.new.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(selectedSegment == nil || selectedSegment == .new ? 1 : 0.4)
                            .cornerRadius(4)
                        }

                        if learningCount > 0 {
                            SectorMark(
                                angle: .value("Count", animatedLearningCount),
                                innerRadius: .ratio(0.55),
                                outerRadius: selectedSegment == .learning ? .ratio(1.0) : .ratio(0.95),
                                angularInset: 2
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: MasterySegment.learning.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(selectedSegment == nil || selectedSegment == .learning ? 1 : 0.4)
                            .cornerRadius(4)
                        }

                        if reviewingCount > 0 {
                            SectorMark(
                                angle: .value("Count", animatedReviewingCount),
                                innerRadius: .ratio(0.55),
                                outerRadius: selectedSegment == .reviewing ? .ratio(1.0) : .ratio(0.95),
                                angularInset: 2
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: MasterySegment.reviewing.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(selectedSegment == nil || selectedSegment == .reviewing ? 1 : 0.4)
                            .cornerRadius(4)
                        }

                        if masteredCount > 0 {
                            SectorMark(
                                angle: .value("Count", animatedMasteredCount),
                                innerRadius: .ratio(0.55),
                                outerRadius: selectedSegment == .mastered ? .ratio(1.0) : .ratio(0.95),
                                angularInset: 2
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: MasterySegment.mastered.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(selectedSegment == nil || selectedSegment == .mastered ? 1 : 0.4)
                            .cornerRadius(4)
                        }
                    }
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            if let plotFrame = chartProxy.plotFrame {
                                let frame = geometry[plotFrame]
                                ZStack {
                                    // Inner glow
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [.clear, Color(.systemBackground).opacity(0.5)],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: frame.width * 0.25
                                            )
                                        )
                                        .frame(width: frame.width * 0.5, height: frame.height * 0.5)

                                    // Center content
                                    VStack(spacing: 4) {
                                        if let segment = selectedSegment {
                                            Image(systemName: segment.icon)
                                                .font(.title2)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: segment.colors,
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                            Text("\(count(for: segment))")
                                                .font(.title2.bold())
                                                .contentTransition(.numericText())
                                            Text(segment.label)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("\(Int(masteredPercentage))%")
                                                .font(.title.bold())
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.green, .mint],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .contentTransition(.numericText())
                                            Text("已掌握")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedSegment)
                }

                // Legend
                HStack(spacing: 16) {
                    ForEach(MasterySegment.allCases, id: \.rawValue) { segment in
                        if count(for: segment) > 0 {
                            MasteryLegendItem(
                                segment: segment,
                                count: count(for: segment),
                                isSelected: selectedSegment == segment,
                                onTap: {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedSegment == segment {
                                            selectedSegment = nil
                                        } else {
                                            selectedSegment = segment
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
    }
}

// MARK: - Legend Item

private struct MasteryLegendItem: View {
    let segment: MasteryPieChart.MasterySegment
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: segment.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 12)
                    .shadow(color: segment.colors.first?.opacity(0.3) ?? .clear, radius: isSelected ? 4 : 0)

                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? segment.colors.first ?? .primary : .primary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    MasteryPieChart(
        newCount: 50,
        learningCount: 30,
        reviewingCount: 15,
        masteredCount: 20
    )
    .frame(height: 200)
    .padding()
}
