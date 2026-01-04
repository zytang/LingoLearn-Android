"use client";
import React, { useState } from 'react';
import QuizSession from '@/components/QuizSession';
import { QuizMode } from '@/lib/gameLogic';

export default function PracticePage() {
    const [mode, setMode] = useState<QuizMode | null>(null);

    if (mode) {
        return <QuizSession mode={mode} onExit={() => setMode(null)} />;
    }

    return (
        <div className="text-center mt-4">
            <h1 className="text-2xl font-bold mb-4">Practice</h1>
            <p className="mb-8 opacity-70">Select a mode to challenge yourself</p>

            <div className="flex flex-col gap-4 mt-4 max-w-sm mx-auto">
                <button
                    className="btn btn-outline text-lg"
                    onClick={() => setMode('choice')}
                >
                    📝 Multiple Choice
                </button>
                <button
                    className="btn btn-outline text-lg"
                    onClick={() => setMode('spelling')}
                >
                    ⌨️ Spelling
                </button>
                <button
                    className="btn btn-outline text-lg"
                    onClick={() => setMode('listening')}
                >
                    🎧 Listening
                </button>
            </div>
        </div>
    );
}
