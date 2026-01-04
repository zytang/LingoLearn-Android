"use client";
import React, { useState } from 'react';
import styles from './FlashCard.module.css';
import { Word } from '@/types';

interface FlashCardProps {
    word: Word;
    isFlipped: boolean;
    onFlip: () => void;
    onKnow: () => void;
    onUnknown: () => void;
}

const FlashCard: React.FC<FlashCardProps> = ({ word, isFlipped, onFlip, onKnow, onUnknown }) => {

    const speak = (e: React.MouseEvent) => {
        e.stopPropagation();
        const utterance = new SpeechSynthesisUtterance(word.english);
        utterance.lang = 'en-US';
        window.speechSynthesis.speak(utterance);
    };

    return (
        <div className={styles.container}>
            <div
                className={`${styles.card} ${isFlipped ? styles.flipped : ''}`}
                onClick={onFlip}
            >
                <div className={styles.cardInner}>
                    <div className={styles.front}>
                        <button className={styles.speaker} onClick={speak}>🔊</button>
                        <div className={styles.word}>{word.english}</div>
                        <div className={styles.phonetic}>{word.phonetic}</div>
                        <div className={styles.hint}>(Tap to flip)</div>
                    </div>

                    <div className={styles.back}>
                        <div className={styles.definition}>{word.chinese}</div>
                        <div className={styles.part}>{word.partOfSpeech}</div>
                        <div className={styles.example}>
                            <p className={styles.enSentence}>{word.exampleSentence}</p>
                            <p className={styles.cnSentence}>{word.exampleTranslation}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div className={styles.controls}>
                <button
                    className={`${styles.btn} ${styles.btnUnknown}`}
                    onClick={onUnknown}
                >
                    Don't Know (Left)
                </button>
                <button
                    className={`${styles.btn} ${styles.btnKnow}`}
                    onClick={onKnow}
                >
                    Know (Right)
                </button>
            </div>
        </div>
    );
};

export default FlashCard;
