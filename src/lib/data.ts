import cet4Data from '@/data/cet4_words.json';
import cet6Data from '@/data/cet6_words.json';
import { Word, WordCategory } from '@/types';

export const getWords = (category: 'CET4' | 'CET6' = 'CET4'): Word[] => {
    if (category === 'CET6') {
        return (cet6Data as unknown as WordCategory).words;
    }
    return (cet4Data as unknown as WordCategory).words;
};

export const getAllWords = (): Word[] => {
    return [
        ...(cet4Data as unknown as WordCategory).words,
        ...(cet6Data as unknown as WordCategory).words,
    ];
};

export const getWordsByIds = (ids: string[]): Word[] => {
    const all = getAllWords();
    return all.filter(w => ids.includes(w.english));
};
