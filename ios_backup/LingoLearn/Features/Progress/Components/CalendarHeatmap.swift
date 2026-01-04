//
//  CalendarHeatmap.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct CalendarHeatmap: View {
    let dailyProgress: [DailyProgress]
    @State private var selectedMonth: Date = Date()
    @State private var selectedDayInfo: DayInfo?
    @State private var showLegend = false

    private let calendar = Calendar.current
    private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]

    private struct DayInfo: Equatable {
        let date: Date
        let wordsLearned: Int
        let intensity: Double
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        previousMonth()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
                .buttonStyle(HeatmapButtonStyle())

                Spacer()

                VStack(spacing: 2) {
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.headline)
                        .contentTransition(.numericText())

                    // Month summary
                    Text(monthSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        nextMonth()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month) ? .tertiary : .primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
                .buttonStyle(HeatmapButtonStyle())
                .disabled(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
            }

            // Tooltip for selected day
            if let info = selectedDayInfo {
                HStack(spacing: 12) {
                    Circle()
                        .fill(intensityGradient(for: info.intensity))
                        .frame(width: 12, height: 12)

                    Text(info.date, format: .dateTime.month(.abbreviated).day())
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.caption)
                        Text("\(info.wordsLearned) 词")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.accentColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }

            // Heatmap Grid
            VStack(spacing: 6) {
                // Weekday headers
                HStack(spacing: 4) {
                    ForEach(weekdayLabels, id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(daysInMonth, id: \.self) { date in
                        if let date = date {
                            DayCell(
                                date: date,
                                intensity: intensityForDate(date),
                                wordsLearned: wordsLearnedForDate(date),
                                isSelected: selectedDayInfo?.date == date,
                                onSelect: { info in
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if selectedDayInfo?.date == info.date {
                                            selectedDayInfo = nil
                                        } else {
                                            selectedDayInfo = DayInfo(
                                                date: info.date,
                                                wordsLearned: info.wordsLearned,
                                                intensity: info.intensity
                                            )
                                        }
                                    }
                                }
                            )
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 8) {
                Text("少")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(intensityGradient(for: intensity))
                        .frame(width: 16, height: 16)
                }

                Text("多")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }

    private var monthSummary: String {
        let monthProgress = dailyProgress.filter { progress in
            calendar.isDate(progress.date, equalTo: selectedMonth, toGranularity: .month)
        }
        let totalWords = monthProgress.reduce(0) { $0 + $1.wordsLearned }
        let activeDays = monthProgress.filter { $0.wordsLearned > 0 }.count
        return "\(activeDays)天学习, 共\(totalWords)词"
    }

    private func intensityGradient(for intensity: Double) -> LinearGradient {
        let colors: [Color]
        if intensity == 0 {
            colors = [Color(.systemGray5), Color(.systemGray6)]
        } else if intensity >= 0.75 {
            colors = [.green, .mint]
        } else if intensity >= 0.5 {
            colors = [.teal, .cyan]
        } else if intensity >= 0.25 {
            colors = [.blue.opacity(0.8), .cyan.opacity(0.7)]
        } else {
            colors = [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.3)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 0

        var days: [Date?] = []

        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Add days of the month
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }

    private func intensityForDate(_ date: Date) -> Double {
        guard let progress = dailyProgress.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
            return 0
        }

        let wordsLearned = progress.wordsLearned
        if wordsLearned == 0 { return 0 }
        if wordsLearned < 5 { return 0.25 }
        if wordsLearned < 10 { return 0.5 }
        if wordsLearned < 20 { return 0.75 }
        return 1.0
    }

    private func wordsLearnedForDate(_ date: Date) -> Int {
        guard let progress = dailyProgress.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
            return 0
        }
        return progress.wordsLearned
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth),
           newDate <= Date() {
            selectedMonth = newDate
        }
    }
}

struct DayCell: View {
    let date: Date
    let intensity: Double
    let wordsLearned: Int
    let isSelected: Bool
    let onSelect: ((date: Date, wordsLearned: Int, intensity: Double)) -> Void

    @State private var isPressed = false

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var isFuture: Bool {
        date > Date()
    }

    private var backgroundGradient: LinearGradient {
        if isFuture {
            return LinearGradient(colors: [Color(.systemGray6).opacity(0.5)], startPoint: .top, endPoint: .bottom)
        }
        if intensity == 0 {
            return LinearGradient(colors: [Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
        }
        // Gradient based on intensity
        let colors: [Color]
        if intensity >= 0.75 {
            colors = [.green, .mint]
        } else if intensity >= 0.5 {
            colors = [.teal, .cyan]
        } else if intensity >= 0.25 {
            colors = [.blue.opacity(0.8), .cyan.opacity(0.7)]
        } else {
            colors = [.accentColor.opacity(0.4), .accentColor.opacity(0.3)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundGradient)
                .shadow(
                    color: intensity > 0 ? .accentColor.opacity(0.2) : .clear,
                    radius: isSelected ? 4 : 0,
                    y: isSelected ? 2 : 0
                )

            // Today indicator ring
            if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }

            // Selection indicator
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
            }

            // Day number
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2)
                .fontWeight(isToday || isSelected ? .bold : .medium)
                .foregroundColor(isFuture ? .secondary : (intensity > 0.25 ? .white : .primary))
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.05 : 1.0))
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            guard !isFuture else { return }
            isPressed = true
            onSelect((date, wordsLearned, intensity))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// MARK: - Button Style

private struct HeatmapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    CalendarHeatmap(dailyProgress: [])
        .padding()
}
