import React from 'react';
import styles from './ProgressRing.module.css';

interface ProgressRingProps {
    radius: number;
    stroke: number;
    progress: number; // 0 to 100
}

const ProgressRing: React.FC<ProgressRingProps> = ({ radius, stroke, progress }) => {
    const normalizedRadius = radius - stroke * 2;
    const circumference = normalizedRadius * 2 * Math.PI;
    const strokeDashoffset = circumference - (progress / 100) * circumference;

    return (
        <div className={styles.wrapper}>
            <svg
                height={radius * 2}
                width={radius * 2}
                className={styles.ring}
            >
                <circle
                    className={styles.background}
                    strokeWidth={stroke}
                    r={normalizedRadius}
                    cx={radius}
                    cy={radius}
                />
                <circle
                    className={styles.progress}
                    strokeWidth={stroke}
                    strokeDasharray={circumference + ' ' + circumference}
                    style={{ strokeDashoffset }}

                    r={normalizedRadius}
                    cx={radius}
                    cy={radius}
                />
            </svg>
            <div className={styles.content}>
                <span className={styles.percentage}>{progress}%</span>
                <span className={styles.label}>Completeness</span>
            </div>
        </div>
    );
};

export default ProgressRing;
