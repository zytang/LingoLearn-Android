//
//  ProgressView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct LearningProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProgressViewModel?
    @State private var selectedPeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case week = "7天"
        case month = "30天"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedPeriod) { _, newValue in
                        HapticManager.shared.selection()
                        viewModel?.updatePeriod(newValue == .week ? 7 : 30)
                    }

                    // Stats Cards
                    statsCardsSection

                    // Line Chart
                    lineChartSection

                    // Calendar Heatmap
                    calendarHeatmapSection

                    // Mastery Distribution
                    masteryDistributionSection

                    // Achievement Wall
                    achievementWallSection
                }
                .padding(.vertical)
            }
            .navigationTitle("学习进度")
            .onAppear {
                if viewModel == nil {
                    viewModel = ProgressViewModel(modelContext: modelContext)
                }
                viewModel?.loadData()
            }
        }
    }

    private var statsCardsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "当前连续",
                    value: "\(viewModel?.currentStreak ?? 0)",
                    unit: "天",
                    icon: "flame.fill",
                    color: .orange
                )

                StatCard(
                    title: "最长连续",
                    value: "\(viewModel?.longestStreak ?? 0)",
                    unit: "天",
                    icon: "star.fill",
                    color: .yellow
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "总学习词汇",
                    value: "\(viewModel?.totalWordsLearned ?? 0)",
                    unit: "个",
                    icon: "book.fill",
                    color: .blue
                )

                StatCard(
                    title: "总学习时长",
                    value: viewModel?.formattedTotalStudyTime ?? "0分钟",
                    unit: "",
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
    }

    private var lineChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressSectionHeader(title: "学习趋势", icon: "chart.line.uptrend.xyaxis", color: .blue)
                .padding(.horizontal)

            WeeklyLineChart(data: viewModel?.chartData ?? [])
                .frame(height: 200)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.05), .cyan.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .blue.opacity(0.08), radius: 8, y: 4)
                .padding(.horizontal)
        }
    }

    private var calendarHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressSectionHeader(title: "学习日历", icon: "calendar", color: .green)
                .padding(.horizontal)

            CalendarHeatmap(dailyProgress: viewModel?.dailyProgressData ?? [])
                .frame(height: 180)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.05), .mint.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.green.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .green.opacity(0.08), radius: 8, y: 4)
                .padding(.horizontal)
        }
    }

    private var masteryDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressSectionHeader(title: "掌握度分布", icon: "chart.pie", color: .purple)
                .padding(.horizontal)

            VStack(spacing: 16) {
                MasteryPieChart(
                    newCount: viewModel?.newCount ?? 0,
                    learningCount: viewModel?.learningCount ?? 0,
                    reviewingCount: viewModel?.reviewingCount ?? 0,
                    masteredCount: viewModel?.masteredCount ?? 0
                )
                .frame(height: 200)

                // Legend
                HStack(spacing: 16) {
                    LegendItem(color: .gray, label: "新学", count: viewModel?.newCount ?? 0)
                    LegendItem(color: .orange, label: "学习中", count: viewModel?.learningCount ?? 0)
                    LegendItem(color: .blue, label: "复习中", count: viewModel?.reviewingCount ?? 0)
                    LegendItem(color: .green, label: "已掌握", count: viewModel?.masteredCount ?? 0)
                }
                .font(.caption)
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.05), .pink.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.purple.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .purple.opacity(0.08), radius: 8, y: 4)
            .padding(.horizontal)
        }
    }

    private var achievementWallSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressSectionHeader(title: "成就墙", icon: "trophy.fill", color: .yellow)
                .padding(.horizontal)

            AchievementWall(
                unlockedAchievements: viewModel?.unlockedAchievements ?? [],
                onAchievementTap: { achievement in
                    // Show achievement details
                }
            )
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.05), .orange.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.yellow.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .yellow.opacity(0.08), radius: 8, y: 4)
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    @State private var isAnimating = false
    @State private var glowOpacity: Double = 0
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 8,
                                endRadius: 22
                            )
                        )
                        .frame(width: 40, height: 40)
                        .opacity(glowOpacity)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.15), color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.bounce, value: isAnimating)
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))

                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.06), color.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.08), radius: 8, y: 4)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
                glowOpacity = 1.0
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 8
                        )
                    )
                    .frame(width: 14, height: 14)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 8)
            }

            Text(label)
                .fontWeight(.medium)

            Text("\(count)")
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Section Header

struct ProgressSectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 16
                        )
                    )
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.8)

            Text(title)
                .font(.headline)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -10)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

#Preview {
    LearningProgressView()
        .modelContainer(for: [DailyProgress.self, UserStats.self, Word.self])
}
