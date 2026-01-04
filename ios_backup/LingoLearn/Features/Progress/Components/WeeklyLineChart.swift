//
//  WeeklyLineChart.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import Charts

struct WeeklyLineChart: View {
    let data: [(date: Date, count: Int)]
    var showAverage: Bool = true
    var showTrend: Bool = true

    @State private var animationProgress: CGFloat = 0
    @State private var selectedDate: Date?
    @State private var selectedCount: Int?
    @State private var hasAppeared = false

    private var average: Double {
        guard !data.isEmpty else { return 0 }
        return Double(data.map(\.count).reduce(0, +)) / Double(data.count)
    }

    private var trend: TrendDirection {
        guard data.count >= 2 else { return .stable }
        let firstHalf = data.prefix(data.count / 2).map(\.count).reduce(0, +)
        let secondHalf = data.suffix(data.count / 2).map(\.count).reduce(0, +)
        let difference = Double(secondHalf - firstHalf) / Double(max(firstHalf, 1))
        if difference > 0.15 { return .up }
        if difference < -0.15 { return .down }
        return .stable
    }

    private enum TrendDirection {
        case up, down, stable

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .orange
            case .stable: return .blue
            }
        }

        var label: String {
            switch self {
            case .up: return "上升趋势"
            case .down: return "下降趋势"
            case .stable: return "稳定"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with stats
            HStack(spacing: 16) {
                // Selected value or average display
                if let date = selectedDate, let count = selectedCount {
                    selectedValueBadge(date: date, count: count)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                } else if showAverage {
                    averageBadge
                        .transition(.opacity)
                }

                Spacer()

                // Trend indicator
                if showTrend {
                    trendBadge
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedDate)

            Chart {
                // Average line
                if showAverage {
                    RuleMark(y: .value("Average", average * animationProgress))
                        .foregroundStyle(Color.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("平均")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 4)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(Capsule())
                                .opacity(animationProgress)
                        }
                }

                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    // Area with gradient
                    AreaMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Words", Double(item.count) * animationProgress)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.35),
                                Color.accentColor.opacity(0.15),
                                Color.accentColor.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    // Line
                    LineMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Words", Double(item.count) * animationProgress)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    // Points
                    PointMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Words", Double(item.count) * animationProgress)
                    )
                    .foregroundStyle(pointColor(for: item.count))
                    .symbolSize(selectedDate == item.date ? 150 : 60)
                    .symbol {
                        Circle()
                            .fill(pointColor(for: item.count))
                            .frame(width: selectedDate == item.date ? 14 : 8)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: selectedDate == item.date ? 6 : 3)
                            )
                            .shadow(color: pointColor(for: item.count).opacity(0.4), radius: 3, y: 2)
                    }
                }

                // Selection rule line
                if let date = selectedDate {
                    RuleMark(x: .value("Selected", date, unit: .day))
                        .foregroundStyle(Color.accentColor.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 2]))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            VStack(spacing: 2) {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption2)
                                    .fontWeight(isToday(date) ? .bold : .regular)
                                    .foregroundStyle(isToday(date) ? Color.accentColor : Color.secondary)
                                if isToday(date) {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateSelection(at: value.location, proxy: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            selectedDate = nil
                                            selectedCount = nil
                                        }
                                    }
                                }
                        )
                }
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
                animationProgress = 1
            }
        }
    }

    // MARK: - Subviews

    private func selectedValueBadge(date: Date, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(date, format: .dateTime.month().day())
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                    .contentTransition(.numericText())
                Text("个单词")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var averageBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.caption)
                .foregroundStyle(.orange)

            Text("日均")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(format: "%.1f", average))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .clipShape(Capsule())
    }

    private var trendBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(trend.color)
                .symbolEffect(.pulse, value: hasAppeared)

            Text(trend.label)
                .font(.caption2)
                .foregroundStyle(trend.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(trend.color.opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Helpers

    private func pointColor(for count: Int) -> Color {
        let maxCount = data.map(\.count).max() ?? 1
        let ratio = Double(count) / Double(maxCount)
        if ratio >= 0.8 { return .green }
        if ratio >= 0.5 { return .accentColor }
        return .orange
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func updateSelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x

        if let date: Date = proxy.value(atX: xPosition) {
            if let closest = data.min(by: {
                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
            }) {
                if selectedDate != closest.date {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        selectedDate = closest.date
                        selectedCount = closest.count
                    }
                    HapticManager.shared.selection()
                }
            }
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<7).map { day in
        let date = calendar.date(byAdding: .day, value: -day, to: today)!
        return (date: date, count: Int.random(in: 5...30))
    }.reversed()

    return WeeklyLineChart(data: Array(sampleData))
        .frame(height: 200)
        .padding()
}
