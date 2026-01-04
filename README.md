# LingoLearn Web / Android

This is a Next.js adaptation of the LingoLearn iOS app, designed to run on Android (as a PWA) and the Web.

## Features
- **Progress Tracking**: Daily goals, streaks, and visuals.
- **Flashcards**: 3D Flip animation, Spoken audio (TTS), Swipe-like interaction.
- **Responsive Design**: Optimized for mobile screens.
- **PWA Support**: Installable on Android devices.

## Setup & Run

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Run Development Server**:
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000).

3. **Build for Vercel**:
   This project is ready for Vercel. Simply import this repository into Vercel and deploy.

## Project Structure
- `src/app`: Pages and Layouts (Next.js App Router).
- `src/components`: Reusable UI components.
- `src/data`: JSON word data (CET4, CET6).
- `ios_backup`: Original iOS Source Code.
