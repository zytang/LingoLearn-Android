"use client";
import React, { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import FlashCard from '@/components/FlashCard';
import { getWords, getWordsByIds } from '@/lib/data'; // Import updated data helpers
import { Word } from '@/types';
import styles from './page.module.css';

import { incrementLearnedCount, addToReviewQueue, removeFromReviewQueue, getReviewQueue } from '@/lib/userProgress';

function LearnContent() {
    const router = useRouter();
    const searchParams = useSearchParams(); // using searchParams causes client-side bail out if not suspended
    const mode = searchParams.get('mode') || 'learn';
    const [words, setWords] = useState<Word[]>([]);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [sessionStats, setSessionStats] = useState({ know: 0, unknown: 0 });
    const [isFinished, setIsFinished] = useState(false);
    const [isFlipped, setIsFlipped] = useState(false);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadWords = async () => {
            await new Promise(resolve => setTimeout(resolve, 500));

            let selectedWords: Word[] = [];

            if (mode === 'review') {
                const reviewIds = getReviewQueue();
                if (reviewIds.length > 0) {
                    selectedWords = getWordsByIds(reviewIds);
                }
            } else {
                // Normal Learning Mode
                const allWords = getWords('CET4');
                const shuffled = [...allWords].sort(() => 0.5 - Math.random());
                selectedWords = shuffled.slice(0, 10);
            }

            setWords(selectedWords);
            setLoading(false);
        };
        loadWords();
    }, [mode]);

    const handleNext = () => {
        if (currentIndex < words.length - 1) {
            setCurrentIndex(prev => prev + 1);
            setIsFlipped(false);
        } else {
            setIsFinished(true);
        }
    };

    const handleKnown = () => {
        setSessionStats(prev => ({ ...prev, know: prev.know + 1 }));

        if (mode === 'review') {
            const currentWord = words[currentIndex];
            if (currentWord) removeFromReviewQueue(currentWord.english);
        } else {
            incrementLearnedCount(1);
        }

        handleNext();
    };

    const handleUnknown = () => {
        setSessionStats(prev => ({ ...prev, unknown: prev.unknown + 1 }));

        const currentWord = words[currentIndex];
        if (currentWord) addToReviewQueue(currentWord.english);

        handleNext();
    };

    if (loading) return <div className="text-center mt-4">Loading...</div>;

    if (words.length === 0) {
        return (
            <div className={styles.summaryContainer}>
                {mode === 'review' ? (
                    <>
                        <h1 style={{ marginBottom: '1rem' }}>All Caught Up! 🌟</h1>
                        <p style={{ opacity: 0.6, marginBottom: '2rem' }}>No words to review right now.</p>
                    </>
                ) : (
                    <h1>No words found.</h1>
                )}
                <button className={styles.finishBtn} onClick={() => router.push('/')}>
                    Return Home
                </button>
            </div>
        );
    }

    if (isFinished) {
        return (
            <div className={styles.summaryContainer}>
                <h1>Session Complete! 🎉</h1>

                <div className={styles.statsGrid}>
                    <div className={styles.statItem}>
                        <span className={styles.statValue}>{words.length}</span>
                        <span className={styles.statLabel}>Total</span>
                    </div>
                    <div className={`${styles.statItem} ${styles.green}`}>
                        <span className={styles.statValue}>{sessionStats.know}</span>
                        <span className={styles.statLabel}>Known</span>
                    </div>
                    <div className={`${styles.statItem} ${styles.red}`}>
                        <span className={styles.statValue}>{sessionStats.unknown}</span>
                        <span className={styles.statLabel}>To Review</span>
                    </div>
                </div>

                <button className={styles.finishBtn} onClick={() => router.push('/')}>
                    Return Home
                </button>
            </div>
        );
    }

    const progress = ((currentIndex) / words.length) * 100;

    return (
        <div className={styles.container}>
            <div className={styles.progressBar}>
                <div
                    className={styles.progressFill}
                    style={{ width: `${progress}%` }}
                />
            </div>

            <div className={styles.header}>
                <span>Word {currentIndex + 1} / {words.length}</span>
            </div>

            <FlashCard
                word={words[currentIndex]}
                isFlipped={isFlipped}
                onFlip={() => setIsFlipped(!isFlipped)}
                onKnow={handleKnown}
                onUnknown={handleUnknown}
            />
        </div>
    );
}

export default function LearnPage() {
    return (
        <Suspense fallback={<div className="text-center mt-4">Loading environment...</div>}>
            <LearnContent />
        </Suspense>
    );
}
