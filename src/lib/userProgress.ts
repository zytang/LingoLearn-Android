"use client";

const STORAGE_KEY = 'lingolearn_progress_v2';

export interface UserState {
    streak: number;
    lastStudyDate: string;
    dailyGoal: number;
    history: Record<string, number>; // "YYYY-MM-DD": count
    reviewQueue: string[]; // List of Word IDs (english text as ID for simplicity)
}

const DEFAULT_STATE: UserState = {
    streak: 0,
    lastStudyDate: '',
    dailyGoal: 20,
    history: {},
    reviewQueue: [],
};

// In-memory storage to reset on refresh as requested
let memoryState: UserState = {
    streak: 0,
    lastStudyDate: '',
    dailyGoal: 20,
    history: {},
    reviewQueue: [],
};

// Helper: Get today's date string YYYY-MM-DD
const getToday = () => new Date().toISOString().split('T')[0];

export const getUserState = (): UserState => {
    return { ...memoryState };
};

export const saveUserState = (state: UserState) => {
    memoryState = { ...state };
};

export const incrementLearnedCount = (count: number = 1) => {
    const state = getUserState();
    const today = getToday();

    // Update History
    const currentCount = state.history[today] || 0;
    state.history[today] = currentCount + count;

    // Update Streak
    if (state.lastStudyDate !== today) {
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];

        if (state.lastStudyDate === yesterdayStr) {
            state.streak += 1;
        } else {
            state.streak = 1; // Reset or start new
        }
        state.lastStudyDate = today;
    }

    saveUserState(state);
    return state;
};

// Review Queue Logic
export const addToReviewQueue = (wordId: string) => {
    const state = getUserState();
    if (!state.reviewQueue.includes(wordId)) {
        state.reviewQueue.push(wordId);
        saveUserState(state);
    }
};

export const removeFromReviewQueue = (wordId: string) => {
    const state = getUserState();
    state.reviewQueue = state.reviewQueue.filter(id => id !== wordId);
    saveUserState(state);
};

export const getReviewQueue = (): string[] => {
    const state = getUserState();
    return state.reviewQueue || [];
};

// Setters
export const setDailyGoal = (goal: number) => {
    const state = getUserState();
    state.dailyGoal = goal;
    saveUserState(state);
    return state;
};

// Getters for UI
export const getDailyProgress = () => {
    const state = getUserState();
    const today = getToday();
    return {
        learned: state.history[today] || 0,
        goal: state.dailyGoal,
        streak: state.streak,
    };
};

export const getHeatmapData = () => {
    const state = getUserState();
    // Convert Record to Array for Heatmap component
    return Object.entries(state.history).map(([date, count]) => ({ date, count }));
};

export const getTotalLearned = () => {
    const state = getUserState();
    return Object.values(state.history).reduce((a, b) => a + b, 0);
};

export const getReviewCount = () => {
    const state = getUserState();
    return state.reviewQueue ? state.reviewQueue.length : 0;
};

// Compatibility export for Home page existing code
// We mapped 'DailyProgress' in the previous step, let's keep a shape that works
export interface DailyProgress {
    learned: number;
    goal: number;
    streak: number;
}
export const getProgress = (): DailyProgress => getDailyProgress();
