"use client";
import React, { useState, useEffect, useRef } from 'react';
import styles from './GoalEditModal.module.css';

interface GoalEditModalProps {
    isOpen: boolean;
    currentGoal: number;
    onClose: () => void;
    onSave: (newGoal: number) => void;
}

const GoalEditModal: React.FC<GoalEditModalProps> = ({ isOpen, currentGoal, onClose, onSave }) => {
    const [value, setValue] = useState(currentGoal.toString());
    const inputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        if (isOpen) {
            setValue(currentGoal.toString());
            // Focus input after a short delay to allow mount
            setTimeout(() => inputRef.current?.focus(), 100);
        }
    }, [isOpen, currentGoal]);

    const handleSave = () => {
        const num = parseInt(value, 10);
        if (!isNaN(num) && num > 0) {
            onSave(num);
            onClose();
        }
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') handleSave();
        if (e.key === 'Escape') onClose();
    };

    if (!isOpen) return null;

    return (
        <div className={styles.overlay} onClick={onClose}>
            <div className={styles.modal} onClick={e => e.stopPropagation()}>
                <h3 className={styles.title}>Set Daily Goal</h3>
                <p className={styles.subtitle}>How many words do you want to learn today?</p>

                <input
                    ref={inputRef}
                    type="number"
                    className={styles.input}
                    value={value}
                    onChange={(e) => setValue(e.target.value)}
                    onKeyDown={handleKeyDown}
                    min="1"
                    max="100"
                />

                <div className={styles.actions}>
                    <button className={styles.btnCancel} onClick={onClose}>Cancel</button>
                    <button className={styles.btnSave} onClick={handleSave}>Save</button>
                </div>
            </div>
        </div>
    );
};

export default GoalEditModal;
