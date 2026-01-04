"use client";
import React, { useState, useEffect, useRef } from 'react';
import { QuizMode, generateQuestions, Question } from '@/lib/gameLogic';
import styles from './QuizSession.module.css';

interface QuizSessionProps {
    mode: QuizMode;
    onExit: () => void;
}

const QuizSession: React.FC<QuizSessionProps> = ({ mode, onExit }) => {
    const [questions, setQuestions] = useState<Question[]>([]);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [score, setScore] = useState(0);
    const [isFinished, setIsFinished] = useState(false);
    const [loading, setLoading] = useState(true);
    const [selectedOption, setSelectedOption] = useState<string | null>(null);
    const [inputAnswer, setInputAnswer] = useState('');
    const [feedback, setFeedback] = useState<'correct' | 'wrong' | null>(null);
    const [timeLeft, setTimeLeft] = useState(30);

    const timerRef = useRef<NodeJS.Timeout | null>(null);
    const inputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        const q = generateQuestions(mode);
        setQuestions(q);
        setLoading(false);
    }, [mode]);

    useEffect(() => {
        if (!loading && !isFinished && mode === 'spelling') {
            // Small delay to ensure render complete
            setTimeout(() => {
                inputRef.current?.focus();
            }, 100);
        }
    }, [currentIndex, loading, isFinished, mode]);

    useEffect(() => {
        if (loading || isFinished) return;

        // Reset timer for new question
        setTimeLeft(30);

        timerRef.current = setInterval(() => {
            setTimeLeft(prev => {
                if (prev <= 1) {
                    handleTimeUp();
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        return () => {
            if (timerRef.current) clearInterval(timerRef.current);
        };
    }, [currentIndex, loading, isFinished]);

    const handleTimeUp = () => {
        if (timerRef.current) clearInterval(timerRef.current);
        setFeedback('wrong');
        setTimeout(nextQuestion, 1500);
    };

    const playAudio = (text: string) => {
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = 'en-US';
        window.speechSynthesis.speak(utterance);
    };

    // Auto-play audio for listening mode
    useEffect(() => {
        if (!loading && !isFinished && mode === 'listening' && questions[currentIndex]) {
            playAudio(questions[currentIndex].targetWord.english);
        }
    }, [currentIndex, loading, isFinished, mode, questions]);

    const handleChoiceSelect = (option: string) => {
        if (feedback) return; // Block input during feedback

        if (timerRef.current) clearInterval(timerRef.current);

        const currentQ = questions[currentIndex];
        setSelectedOption(option);

        if (option === currentQ.correctAnswer) {
            setFeedback('correct');
            setScore(s => s + 1);
        } else {
            setFeedback('wrong');
        }

        setTimeout(nextQuestion, 1000);
    };

    const handleSpellingSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (feedback) return;

        if (timerRef.current) clearInterval(timerRef.current);

        const currentQ = questions[currentIndex];
        if (inputAnswer.trim().toLowerCase() === currentQ.correctAnswer.toLowerCase()) {
            setFeedback('correct');
            setScore(s => s + 1);
        } else {
            setFeedback('wrong');
        }

        setTimeout(nextQuestion, 1000);
    };

    const nextQuestion = () => {
        setFeedback(null);
        setSelectedOption(null);
        setInputAnswer('');

        if (currentIndex < questions.length - 1) {
            setCurrentIndex(prev => prev + 1);
        } else {
            setIsFinished(true);
        }
    };

    if (loading) return <div className={styles.loading}>Generating Quiz...</div>;

    if (isFinished) {
        return (
            <div className={styles.resultContainer}>
                <div className={styles.trophy}>🏆</div>
                <h2>Quiz Complete!</h2>
                <div className={styles.scoreBoard}>
                    <div className={styles.scoreItem}>
                        <span>Score</span>
                        <span className={styles.bigNum}>{Math.round((score / questions.length) * 100)}%</span>
                    </div>
                    <div className={styles.scoreItem}>
                        <span>Correct</span>
                        <span className={styles.bigNum}>{score}/{questions.length}</span>
                    </div>
                </div>
                <button className={styles.exitBtn} onClick={onExit}>Back to Menu</button>
            </div>
        );
    }

    const currentQ = questions[currentIndex];
    const progress = ((currentIndex) / questions.length) * 100;

    return (
        <div className={styles.container}>
            {/* Header */}
            <div className={styles.header}>
                <div className={styles.progressBar}>
                    <div className={styles.progressFill} style={{ width: `${progress}%` }} />
                </div>
                <div className={styles.meta}>
                    <span>{currentIndex + 1}/{questions.length}</span>
                    <span className={`${styles.timer} ${timeLeft < 10 ? styles.danger : ''}`}>
                        ⏱ {timeLeft}s
                    </span>
                </div>
            </div>

            {/* Content */}
            <div className={styles.content}>

                {/* Helper visuals based on mode */}
                {mode === 'choice' && (
                    <div className={styles.questionCard}>
                        <h1 className={styles.targetWord}>{currentQ.targetWord.english}</h1>
                        <div className={styles.phonetic}>{currentQ.targetWord.phonetic}</div>
                    </div>
                )}

                {mode === 'listening' && (
                    <div className={styles.questionCard}>
                        <button
                            className={styles.playBtn}
                            onClick={() => playAudio(currentQ.targetWord.english)}
                        >
                            🔊 Tap to Listen
                        </button>
                    </div>
                )}

                {mode === 'spelling' && (
                    <div className={styles.questionCard}>
                        <h1 className={styles.targetChinese}>{currentQ.targetWord.chinese}</h1>
                        <div className={styles.hint}>{currentQ.targetWord.partOfSpeech}</div>
                    </div>
                )}


                {/* Inputs */}
                {(mode === 'choice' || mode === 'listening') && (
                    <div className={styles.optionsGrid}>
                        {currentQ.options?.map((opt, idx) => {
                            let stateClass = '';
                            if (feedback === 'correct' && opt === currentQ.correctAnswer) stateClass = styles.correct;
                            if (feedback === 'wrong' && opt === selectedOption && opt !== currentQ.correctAnswer) stateClass = styles.wrong;
                            if (feedback === 'wrong' && opt === currentQ.correctAnswer) stateClass = styles.correct; // Show correct ans

                            return (
                                <button
                                    key={idx}
                                    className={`${styles.optionBtn} ${stateClass}`}
                                    onClick={() => handleChoiceSelect(opt)}
                                    disabled={!!feedback}
                                >
                                    {opt}
                                </button>
                            );
                        })}
                    </div>
                )}

                {mode === 'spelling' && (
                    <form onSubmit={handleSpellingSubmit} className={styles.spellingForm}>
                        <input
                            ref={inputRef}
                            type="text"
                            className={`${styles.input} ${feedback === 'correct' ? styles.inputCorrect : feedback === 'wrong' ? styles.inputWrong : ''}`}
                            value={inputAnswer}
                            onChange={(e) => setInputAnswer(e.target.value)}
                            placeholder="Type English word..."
                            autoFocus
                            autoCapitalize="none"
                            autoComplete="off"
                            disabled={!!feedback}
                        />
                        {feedback === 'wrong' && (
                            <div className={styles.correctAnswerReveal}>
                                Answer: {currentQ.correctAnswer}
                            </div>
                        )}
                        <button type="submit" className={styles.submitBtn} disabled={!!feedback}>Check</button>
                    </form>
                )}
            </div>
        </div>
    );
};

export default QuizSession;
