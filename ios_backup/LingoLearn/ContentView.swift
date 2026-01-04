//
//  ContentView.swift
//  LingoLearn
//
//  Created by charles qin on 12/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [UserSettings]
    @Query private var allWords: [Word]
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    @State private var previousTab = 0

    private var settings: UserSettings? {
        settingsArray.first
    }

    private var wordsDueForReview: Int {
        let now = Date()
        return allWords.filter { word in
            guard let nextReview = word.nextReviewDate else { return false }
            return nextReview <= now && word.masteryLevel != .new
        }.count
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(hasCompletedOnboarding: Binding(
                    get: { !showOnboarding },
                    set: { completed in
                        if completed {
                            completeOnboarding()
                        }
                    }
                ))
                .transition(.opacity)
            } else {
                mainTabView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showOnboarding)
        .onAppear {
            checkOnboardingStatus()
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            FlashcardView(mode: .learning)
                .tabItem {
                    Label("学习", systemImage: selectedTab == 1 ? "book.fill" : "book")
                }
                .badge(wordsDueForReview > 0 ? "\(min(wordsDueForReview, 99))" : nil)
                .tag(1)

            PracticeMenuView()
                .tabItem {
                    Label("练习", systemImage: selectedTab == 2 ? "gamecontroller.fill" : "gamecontroller")
                }
                .tag(2)

            LearningProgressView()
                .tabItem {
                    Label("进度", systemImage: selectedTab == 3 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                }
                .tag(4)
        }
        .tint(.primaryBlue)
        .onChange(of: selectedTab) { oldValue, newValue in
            HapticManager.shared.selection()
            previousTab = oldValue
        }
    }

    private func checkOnboardingStatus() {
        // If no settings exist yet, show onboarding (first launch)
        if settings == nil {
            showOnboarding = true
        } else if let existingSettings = settings {
            showOnboarding = !existingSettings.hasCompletedOnboarding
        }
    }

    private func completeOnboarding() {
        if let existingSettings = settings {
            existingSettings.hasCompletedOnboarding = true
        } else {
            // Create new settings with onboarding completed
            let newSettings = UserSettings(hasCompletedOnboarding: true)
            modelContext.insert(newSettings)
        }
        try? modelContext.save()
        showOnboarding = false
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Word.self, StudySession.self, DailyProgress.self, UserStats.self, UserSettings.self])
}
