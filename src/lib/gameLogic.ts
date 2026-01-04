export type QuizMode = 'choice' | 'spelling' | 'listening';

export interface Question {
    id: string;
    type: QuizMode;
    targetWord: any; // Using 'any' for now to avoid circular dependency with types/index.ts if strictly imported, but better to import Word
    options?: string[]; // For choice/listening
    correctAnswer: string;
}

import { Word } from "@/types";
import { getWords } from "./data";

export const generateQuestions = (mode: QuizMode, count: number = 10): Question[] => {
    const allWords = getWords('CET4'); // Default to CET4 for now
    const questions: Question[] = [];

    // Shuffle words for random selection
    const pool = [...allWords].sort(() => 0.5 - Math.random());

    for (let i = 0; i < Math.min(count, pool.length); i++) {
        const target = pool[i];

        if (mode === 'choice') {
            // Pick 3 distractors
            const distractors = allWords
                .filter(w => w.english !== target.english)
                .sort(() => 0.5 - Math.random())
                .slice(0, 3)
                .map(w => w.chinese);

            const options = [...distractors, target.chinese].sort(() => 0.5 - Math.random());

            questions.push({
                id: target.english,
                type: 'choice',
                targetWord: target,
                options,
                correctAnswer: target.chinese
            });
        }
        else if (mode === 'listening') {
            // Pick 3 distractors
            const distractors = allWords
                .filter(w => w.english !== target.english)
                .sort(() => 0.5 - Math.random())
                .slice(0, 3)
                .map(w => w.english);

            const options = [...distractors, target.english].sort(() => 0.5 - Math.random());

            questions.push({
                id: target.english,
                type: 'listening',
                targetWord: target,
                options,
                correctAnswer: target.english
            });
        }
        else if (mode === 'spelling') {
            questions.push({
                id: target.english,
                type: 'spelling',
                targetWord: target,
                correctAnswer: target.english
            });
        }
    }

    return questions;
};
