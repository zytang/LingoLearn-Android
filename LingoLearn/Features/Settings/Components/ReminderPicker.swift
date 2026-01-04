//
//  ReminderPicker.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI

struct ReminderPicker: View {
    @Binding var time: Date
    @State private var isExpanded = false

    private var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: time)
        switch hour {
        case 5..<12: return .morning
        case 12..<14: return .noon
        case 14..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    private enum TimeOfDay {
        case morning, noon, afternoon, evening, night

        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .noon: return "sun.max.fill"
            case .afternoon: return "sun.haze.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.stars.fill"
            }
        }

        var color: Color {
            switch self {
            case .morning: return .orange
            case .noon: return .yellow
            case .afternoon: return .orange
            case .evening: return .pink
            case .night: return .purple
            }
        }

        var label: String {
            switch self {
            case .morning: return "早晨"
            case .noon: return "中午"
            case .afternoon: return "下午"
            case .evening: return "傍晚"
            case .night: return "夜间"
            }
        }

        var suggestion: String {
            switch self {
            case .morning: return "适合开始新的一天"
            case .noon: return "午休后学习效果好"
            case .afternoon: return "下午茶时间学习"
            case .evening: return "晚饭后放松学习"
            case .night: return "睡前记忆更深刻"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            Button(action: {
                HapticManager.shared.selection()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [timeOfDay.color.opacity(0.2), timeOfDay.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Image(systemName: timeOfDay.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [timeOfDay.color, timeOfDay.color.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .symbolEffect(.pulse, value: isExpanded)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("提醒时间")
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(timeOfDay.suggestion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Time badge
                    HStack(spacing: 4) {
                        Text(time, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(timeOfDay.color)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(timeOfDay.color.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)

            // Expanded picker
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .padding(.top, 12)

                    // Quick time presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickPresets, id: \.label) { preset in
                                QuickTimeButton(
                                    label: preset.label,
                                    icon: preset.icon,
                                    color: preset.color,
                                    isSelected: isTimeNear(preset.hour, preset.minute),
                                    action: {
                                        HapticManager.shared.selection()
                                        setTime(hour: preset.hour, minute: preset.minute)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // Date picker
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 150)
                    .onChange(of: time) { _, _ in
                        HapticManager.shared.selection()
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .padding(.vertical, 4)
    }

    private struct TimePreset {
        let label: String
        let icon: String
        let hour: Int
        let minute: Int
        let color: Color
    }

    private var quickPresets: [TimePreset] {
        [
            TimePreset(label: "早晨", icon: "sunrise.fill", hour: 7, minute: 0, color: .orange),
            TimePreset(label: "上午", icon: "sun.max.fill", hour: 9, minute: 0, color: .yellow),
            TimePreset(label: "午后", icon: "sun.haze.fill", hour: 14, minute: 0, color: .orange),
            TimePreset(label: "傍晚", icon: "sunset.fill", hour: 18, minute: 0, color: .pink),
            TimePreset(label: "晚间", icon: "moon.fill", hour: 21, minute: 0, color: .purple)
        ]
    }

    private func isTimeNear(_ hour: Int, _ minute: Int) -> Bool {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: time)
        let currentMinute = calendar.component(.minute, from: time)
        return currentHour == hour && abs(currentMinute - minute) < 15
    }

    private func setTime(hour: Int, minute: Int) {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: time)
        components.hour = hour
        components.minute = minute
        if let newTime = Calendar.current.date(from: components) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                time = newTime
            }
        }
    }
}

// MARK: - Quick Time Button

private struct QuickTimeButton: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(
                        isSelected ?
                            LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )

                Text(label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                            LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [color.opacity(0.1), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    Form {
        ReminderPicker(time: .constant(Date()))
    }
}
