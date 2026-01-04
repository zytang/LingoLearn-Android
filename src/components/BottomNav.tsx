"use client";
import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { IconHome, IconBook, IconPractice, IconStats } from './Icons';
import styles from './BottomNav.module.css';

const BottomNav = () => {
    const pathname = usePathname();

    const isActive = (path: string) => pathname === path;

    return (
        <nav className={styles.nav}>
            <Link href="/" className={`${styles.item} ${isActive('/') ? styles.active : ''}`}>
                <IconHome className={styles.icon} />
                <span>Home</span>
            </Link>
            <Link href="/learn" className={`${styles.item} ${isActive('/learn') ? styles.active : ''}`}>
                <IconBook className={styles.icon} />
                <span>Learn</span>
            </Link>
            <Link href="/practice" className={`${styles.item} ${isActive('/practice') ? styles.active : ''}`}>
                <IconPractice className={styles.icon} />
                <span>Practice</span>
            </Link>
            <Link href="/stats" className={`${styles.item} ${isActive('/stats') ? styles.active : ''}`}>
                <IconStats className={styles.icon} />
                <span>Stats</span>
            </Link>
        </nav>
    );
};

export default BottomNav;
