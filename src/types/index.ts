export interface Word {
  english: string;
  chinese: string;
  phonetic: string;
  partOfSpeech: string;
  exampleSentence: string;
  exampleTranslation: string;
  difficulty: number;
}

export interface WordCategory {
  category: string;
  words: Word[];
}

export interface UserProgress {
  learnedWords: string[]; // List of learned word english text or ids
  dailyGoal: number;
  streak: number;
  lastStudyDate: string; // ISO date
  studyHistory: { date: string; count: number }[];
}
