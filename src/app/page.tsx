"use client";
import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import ProgressRing from '@/components/ProgressRing';
import { IconBook, IconReview, IconPractice, IconFire } from '@/components/Icons';
import { getProgress, DailyProgress, setDailyGoal, getReviewCount } from '@/lib/userProgress';
import GoalEditModal from '@/components/GoalEditModal';
import styles from './page.module.css';

export default function Home() {
  const [progressData, setProgressData] = useState<DailyProgress | null>(null);
  const [reviewCount, setReviewCount] = useState(0);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const loadProgress = () => {
    const data = getProgress();
    setProgressData(data);
    setReviewCount(getReviewCount());
  };

  useEffect(() => {
    loadProgress();
    // Refresh interval to catch updates from other tabs/pages
    const interval = setInterval(loadProgress, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleEditGoal = () => {
    setIsModalOpen(true);
  };

  const handleSaveGoal = (newGoal: number) => {
    setDailyGoal(newGoal);
    loadProgress(); // Reload ui
  };

  // Default values to prevent hydration mismatch or empty render
  const learnedCount = progressData?.learned ?? 0;
  const goal = progressData?.goal ?? 20;
  const streak = progressData?.streak ?? 0;

  const completionPercent = goal > 0 ? Math.min(100, Math.round((learnedCount / goal) * 100)) : 0;

  return (
    <div className={styles.container}>
      <GoalEditModal
        isOpen={isModalOpen}
        currentGoal={goal}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveGoal}
      />

      <header className={styles.header}>
        <div className={styles.brand}>
          <div className={styles.logo}>C</div>
          <h1 className={styles.appName}>Chinglish</h1>
        </div>
        <div className={styles.streakBadge} title="Current Streak">
          <IconFire className={styles.fireIcon} /> {streak} Days
        </div>
      </header>

      {/* Main Navigation / Actions Grid */}
      <div className={styles.gridNav}>
        <Link href="/learn" className={styles.navCard}>
          <div className={`${styles.iconBox} ${styles.blueIcon}`}>
            <IconBook className={styles.svgIcon} />
          </div>
          <span className={styles.navLabel}>Learn</span>
        </Link>

        <Link href="/learn?mode=review" className={styles.navCard}>
          <div className={`${styles.iconBox} ${styles.orangeIcon}`}>
            <IconReview className={styles.svgIcon} />
          </div>
          <span className={styles.navLabel}>Review</span>
          {reviewCount > 0 && <span className={styles.badge} title={`${reviewCount} words to review`}>{reviewCount}</span>}
        </Link>

        <Link href="/practice" className={styles.navCard}>
          <div className={`${styles.iconBox} ${styles.purpleIcon}`}>
            <IconPractice className={styles.svgIcon} />
          </div>
          <span className={styles.navLabel}>Practice</span>
        </Link>
      </div>

      {/* Daily Goal Section */}
      <section className={styles.progressSection}>
        <h2 className={styles.sectionTitle}>Today's Goal</h2>
        <div className={styles.progressCard}>
          <div className={styles.ringWrapper}>
            <ProgressRing radius={60} stroke={10} progress={completionPercent} />
          </div>
          <div className={styles.progressInfo}>
            <div className={styles.statRow}>
              <span className={styles.statVal}>{learnedCount}</span>
              <span className={styles.statLabel}>Learned</span>
            </div>
            <div className={styles.divider}></div>

            {/* Clickable Target Section */}
            <div
              className={`${styles.statRow} ${styles.clickableRow}`}
              onClick={handleEditGoal}
              title="Click to change your daily goal"
              role="button"
              tabIndex={0}
            >
              <span className={`${styles.statVal} ${styles.goalVal}`}>
                {goal}
              </span>
              <span className={`${styles.statLabel} ${styles.goalLabel}`}>
                Set Target ✎
              </span>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
