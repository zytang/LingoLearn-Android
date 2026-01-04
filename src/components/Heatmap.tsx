"use client";
import React from 'react';
import styles from './Heatmap.module.css';

interface HeatmapProps {
    data: { date: string; count: number }[];
    days?: number; // How many days to show (default: 365 or less for mobile)
}

const Heatmap: React.FC<HeatmapProps> = ({ data, days = 91 }) => {
    // Generate last N days
    const today = new Date();
    const dates = [];

    for (let i = days - 1; i >= 0; i--) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        dates.push(d);
    }

    const getColorClass = (count: number) => {
        if (count === 0) return styles.level0;
        if (count <= 5) return styles.level1;
        if (count <= 10) return styles.level2;
        if (count <= 20) return styles.level3;
        return styles.level4;
    };

    const formattedData = new Map(data.map(item => [item.date, item.count]));

    return (
        <div className={styles.container}>
            <div className={styles.grid}>
                {dates.map((date, index) => {
                    const dateStr = date.toISOString().split('T')[0];
                    const count = formattedData.get(dateStr) || 0;

                    return (
                        <div
                            key={dateStr}
                            className={`${styles.cell} ${getColorClass(count)}`}
                            title={`${dateStr}: ${count} words`}
                        />
                    );
                })}
            </div>
            <div className={styles.legend}>
                <span>Less</span>
                <div className={`${styles.cell} ${styles.level0}`} />
                <div className={`${styles.cell} ${styles.level1}`} />
                <div className={`${styles.cell} ${styles.level3}`} />
                <div className={`${styles.cell} ${styles.level4}`} />
                <span>More</span>
            </div>
        </div>
    );
};

export default Heatmap;
