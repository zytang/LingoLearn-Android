//
//  SettingsView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SettingsViewModel?
    @State private var showResetConfirmation = false
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    settingsForm(viewModel: viewModel)
                } else {
                    LoadingView(message: "加载设置...")
                }
            }
            .navigationTitle("设置")
            .onAppear {
                if viewModel == nil {
                    viewModel = SettingsViewModel(modelContext: modelContext)
                    viewModel?.loadSettings()
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    showContent = true
                }
            }
            .alert("重置学习进度", isPresented: $showResetConfirmation) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    HapticManager.shared.warning()
                    viewModel?.resetProgress()
                }
            } message: {
                Text("确定要重置所有学习进度吗？此操作无法撤销。")
            }
        }
    }

    @ViewBuilder
    private func settingsForm(viewModel: SettingsViewModel) -> some View {
        Form {
            // Learning Goal Section
            Section {
                DailyGoalSlider(
                    value: Binding(
                        get: { viewModel.dailyGoal },
                        set: {
                            viewModel.dailyGoal = $0
                            HapticManager.shared.selection()
                        }
                    ),
                    range: 10...100,
                    step: 5
                )
            } header: {
                SettingSectionHeader(icon: "target", title: "学习目标", color: .blue)
            } footer: {
                Text("每天学习 \(viewModel.dailyGoal) 个单词")
            }

            // Reminder Section
            Section {
                Toggle("开启每日提醒", isOn: Binding(
                    get: { viewModel.reminderEnabled },
                    set: { newValue in
                        HapticManager.shared.impact()
                        viewModel.reminderEnabled = newValue
                        Task {
                            await viewModel.handleReminderToggle(newValue)
                        }
                    }
                ))

                if viewModel.reminderEnabled {
                    ReminderPicker(time: Binding(
                        get: { viewModel.reminderTime },
                        set: { newValue in
                            viewModel.reminderTime = newValue
                            Task {
                                await viewModel.scheduleReminder()
                            }
                        }
                    ))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            } header: {
                SettingSectionHeader(icon: "bell.badge", title: "提醒设置", color: .orange)
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.reminderEnabled)

            // Feedback Section
            Section {
                Toggle("声音效果", isOn: Binding(
                    get: { viewModel.soundEnabled },
                    set: {
                        HapticManager.shared.impact()
                        viewModel.soundEnabled = $0
                    }
                ))
                Toggle("触觉反馈", isOn: Binding(
                    get: { viewModel.hapticsEnabled },
                    set: {
                        if $0 { HapticManager.shared.success() }
                        viewModel.hapticsEnabled = $0
                    }
                ))
            } header: {
                SettingSectionHeader(icon: "hand.tap", title: "反馈设置", color: .purple)
            }

            // Pronunciation Section
            Section {
                Toggle("自动播放发音", isOn: Binding(
                    get: { viewModel.autoPlayPronunciation },
                    set: {
                        HapticManager.shared.impact()
                        viewModel.autoPlayPronunciation = $0
                    }
                ))
            } header: {
                SettingSectionHeader(icon: "speaker.wave.2", title: "发音设置", color: .green)
            } footer: {
                Text("学习新单词时自动播放发音")
            }

            // Appearance Section
            Section {
                Picker("外观模式", selection: Binding(
                    get: { viewModel.appearanceMode },
                    set: {
                        HapticManager.shared.selection()
                        viewModel.appearanceMode = $0
                    }
                )) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                SettingSectionHeader(icon: "paintbrush", title: "外观", color: .pink)
            }

            // Vocabulary Section
            Section {
                NavigationLink {
                    WordListView()
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.15), .blue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)

                            Image(systemName: "books.vertical.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        Text("词库管理")
                            .fontWeight(.medium)
                    }
                }
            } header: {
                SettingSectionHeader(icon: "book.closed", title: "词库", color: .cyan)
            } footer: {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.caption2)
                    Text("查看、搜索和管理所有单词")
                }
                .foregroundStyle(.secondary)
            }

            // Data Section
            Section {
                Button(role: .destructive, action: {
                    HapticManager.shared.warning()
                    showResetConfirmation = true
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.red.opacity(0.15), .orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        Text("重置学习进度")
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                    }
                }
            } header: {
                SettingSectionHeader(icon: "externaldrive", title: "数据", color: .gray)
            } footer: {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                    Text("此操作将删除所有学习记录，但保留已学单词")
                }
                .foregroundStyle(.secondary)
            }

            // App Info Section
            Section {
                // Version row
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.15), .cyan.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)

                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }

                // Privacy policy link
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.15), .mint.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)

                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        Text("隐私政策")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Terms link
                Link(destination: URL(string: "https://example.com/terms")!) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.15), .yellow.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)

                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        Text("服务条款")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            } header: {
                SettingSectionHeader(icon: "info.circle", title: "关于", color: .blue)
            }
        }
    }
}

// MARK: - Setting Section Header

struct SettingSectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 12
                        )
                    )
                    .frame(width: 24, height: 24)

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
                .fontWeight(.medium)
                .foregroundStyle(.primary)
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

// Extension to add display name for AppearanceMode
extension AppearanceMode {
    var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self, DailyProgress.self, UserStats.self])
}
