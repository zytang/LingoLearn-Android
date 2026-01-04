"use client";
import React, { useState, useEffect } from 'react';
import Heatmap from '@/components/Heatmap';
import { getHeatmapData, getTotalLearned } from '@/lib/userProgress';

export default function StatsPage() {
    const [heatmapData, setHeatmapData] = useState<{ date: string; count: number }[]>([]);
    const [totalLearned, setTotalLearned] = useState(0);

    useEffect(() => {
        // Load real data
        setHeatmapData(getHeatmapData());
        setTotalLearned(getTotalLearned());
    }, []);

    return (
        <div className="text-center mt-4">
            <h1 className="text-2xl font-bold mb-4">Statistics</h1>

            <div className="card mb-4">
                <h3 className="mb-2">Total Learned</h3>
                <p className="text-2xl font-bold text-primary">{totalLearned}</p>
            </div>

            <div className="card w-full overflow-hidden">
                <h3 className="mb-4">Learning Activity</h3>
                <p className="mb-4 text-sm opacity-60">Last 3 months</p>
                <Heatmap data={heatmapData} />
            </div>
        </div>
    );
}
